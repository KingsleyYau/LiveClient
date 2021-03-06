//
//  VideoHardDecoder.cpp
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//

#include "VideoHardDecoder.h"

#include <common/CommonFunc.h>

#include <rtmpdump/RtmpPlayer.h>

namespace coollive {

typedef struct _tagDecodeItem {
    VideoHardDecoder *decoder;
    int64_t ts;

    _tagDecodeItem() {
        decoder = NULL;
        ts = 0;
    }
} DecodeItem;

/**
 无符号的指数哥伦布编码
 */
static inline unsigned int UE(unsigned char *pBuff, unsigned int nLen, unsigned int &nstartBit) {
    // 计算0bit的个数
    unsigned int nZeroNum = 0;
    while (nstartBit < nLen * 8) {
        unsigned int index = nstartBit;
        unsigned char byte = pBuff[index / 8];
        unsigned char check = (0x80 >> (index % 8));
        if (byte & check) {
            break;
        }
        nZeroNum++;
        nstartBit++;
    }
    nstartBit++;

    unsigned int dwRet = 0;
    for (unsigned int i = 0; i < nZeroNum; i++) {
        dwRet <<= 1;
        unsigned int index = nstartBit;
        unsigned char byte = pBuff[index / 8];
        unsigned char check = (0x80 >> (index % 8));
        if (byte & check) {
            dwRet += 1;
        }
        nstartBit++;
    }
    unsigned int temp = 1 << nZeroNum;
    temp -= 1;
    temp += dwRet;
    return temp;
}

/**
有符号的指数哥伦布编码
*/
static inline int SE(unsigned char *pBuff, unsigned int nLen, unsigned int &nStartBit) {
    int ueVal = UE(pBuff, nLen, nStartBit);
    double k = ueVal;
    int nValue = ceil(k / 2);
    if (ueVal % 2 == 0)
        nValue = -nValue;
    return nValue;
}

/**
 长度为N个bit的无符号数字
 */
static inline unsigned int U(unsigned int bitCount, unsigned char *buf, unsigned int &nstartBit) {
    unsigned int dwRet = 0;
    for (unsigned int i = 0; i < bitCount; i++) {
        dwRet <<= 1;
        unsigned int index = nstartBit;
        unsigned char byte = buf[index / 8];
        unsigned char check = (0x80 >> (index % 8));
        if (byte & check) {
            dwRet += 1;
        }
        nstartBit++;
    }
    return dwRet;
}

VideoHardDecoder::VideoHardDecoder()
    : mRuningMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::VideoHardDecoder( "
                 "this : %p "
                 ")",
                 this);

    mpCallback = NULL;
    mSession = NULL;
    mFormatDesc = NULL;

    mpSps = NULL;
    mSpSize = 0;
    mpPps = NULL;
    mPpsSize = 0;
    mpVps = NULL;
    mVpsSize = 0;
    mNaluHeaderSize = 0;
}

VideoHardDecoder::~VideoHardDecoder() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::~VideoHardDecoder( "
                 "this : %p "
                 ")",
                 this);

    DestroyContext();

    ResetParam();
}

bool VideoHardDecoder::Create(VideoDecoderCallback *callback) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( this : %p )", this);

    bool result = false;
    if (NULL != callback) {
        mpCallback = callback;
        result = true;
    }

    ResetParam();

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( this : %p, [Success] )", this);

    return result;
}

void VideoHardDecoder::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Pause( this : %p )", this);

    DestroyContext();

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Pause( this : %p, [Success] )", this);
}

bool VideoHardDecoder::Reset() {
    bool bFlag = true;
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Reset( this : %p )", this);

    mRuningMutex.lock();
    if (
        mpSps != NULL &&
        mSpSize != 0 &&
        mpPps != NULL &&
        mPpsSize != 0 &&
        mNaluHeaderSize != 0) {
        bFlag = CreateContext();
        mbError = false;
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardDecoder::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoHardDecoder::ResetStream() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::ResetStream( this : %p )", this);
}

void VideoHardDecoder::DecodeVideoKeyFrame(const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, int64_t ts, const char *vps, int vps_size) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::DecodeVideoKeyFrame( "
                 "this : %p, "
                 "sps : %p, "
                 "sps_size : %d, "
                 "pps : %p, "
                 "pps_size : %d, "
                 "vps : %p, "
                 "vps_size : %d, "
                 "naluHeaderSize : %d, "
                 "ts : %lld "
                 ")",
                 this,
                 sps,
                 sps_size,
                 pps,
                 pps_size,
                 vps,
                 vps_size,
                 naluHeaderSize,
                 ts);

    DestroyContext();

    mRuningMutex.lock();

    // 重新设置解码器变量
    if (mpSps) {
        delete[] mpSps;
        mpSps = NULL;
    }
    mSpSize = sps_size;
    mpSps = new char[mSpSize];
    memcpy(mpSps, sps, mSpSize);

    if (mpPps) {
        delete[] mpPps;
        mpPps = NULL;
    }
    mPpsSize = pps_size;
    mpPps = new char[mPpsSize];
    memcpy(mpPps, pps, mPpsSize);

    mNaluHeaderSize = naluHeaderSize;

    if (mpVps) {
        delete[] mpVps;
        mpVps = NULL;
    }
    mVpsSize = vps_size;
    if ( mVpsSize > 0 && vps ) {
        mpVps = new char[mVpsSize];
        memcpy(mpVps, vps, mVpsSize);
    }
    
    if (
        mpSps != NULL &&
        mSpSize != 0 &&
        mpPps != NULL &&
        mPpsSize != 0 &&
        mNaluHeaderSize != 0) {
        CreateContext();
        CheckVideoSize();
    }

    mRuningMutex.unlock();
}

void VideoHardDecoder::DecodeVideoFrame(const char *data, int size, int64_t dts, int64_t pts, VideoFrameType video_type) {
    // 重置解码Buffer
    mVideoDecodeFrame.ResetFrame();

    // 不会对帧重排序, 所以将PTS记录为时间戳
    bool bChange = false;
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bool bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if (bFlag && naluArraySize > 0) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "VideoHardDecoder::DecodeVideoFrame( "
                     "this : %p, "
                     "[Got Nalu Array], "
                     "ts : %lld, "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
                     this,
                     pts,
                     size,
                     naluArraySize);

        int naluIndex = 0;
        while (naluIndex < naluArraySize) {
            Nalu *nalu = naluArray + naluIndex;
            naluIndex++;

            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoHardDecoder::DecodeVideoFrame( "
                         "this : %p, "
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
                         this,
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType());

            Slice *sliceArray = NULL;
            int sliceArraySize = 0;
            int sliceIndex = 0;

            nalu->GetSlices(&sliceArray, sliceArraySize);
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoHardDecoder::DecodeVideoFrame( "
                         "this : %p, "
                         "[Got Slice Array], "
                         "sliceArraySize : %d "
                         ")",
                         this,
                         sliceArraySize);
            while (sliceIndex < sliceArraySize) {
                Slice *slice = sliceArray + sliceIndex;
                sliceIndex++;

                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "VideoHardDecoder::DecodeVideoFrame( "
                             "this : %p, "
                             "[Got Slice], "
                             "sliceSize : %d, "
                             "isFirstSlice : %d "
                             ")",
                             this,
                             slice->GetSliceSize(),
                             slice->IsFirstSlice());

                unsigned char *sliceData = (unsigned char *)slice->GetSlice();
                int sliceLenOriginal = slice->GetSliceSize();
                int sliceLen = CFSwapInt32HostToBig(slice->GetSliceSize());
                mVideoDecodeFrame.AddBuffer((const unsigned char *)&sliceLen, sizeof(sliceLen));
                mVideoDecodeFrame.AddBuffer((const unsigned char *)slice->GetSlice(), slice->GetSliceSize());

                if (nalu->GetNaluType() == VFT_SPS) {
                    if ((mSpSize != sliceLenOriginal) || (0 != memcmp(mpSps, sliceData, sliceLenOriginal))) {
                        if (mSpSize < sliceLenOriginal) {
                            if (mpSps) {
                                delete[] mpSps;
                                mpSps = NULL;
                            }
                            mpSps = new char[sliceLenOriginal];
                        }
                        mSpSize = sliceLenOriginal;
                        memcpy(mpSps, sliceData, mSpSize);

                        FileLevelLog("rtmpdump",
                                     KLog::LOG_MSG,
                                     "VideoHardDecoder::DecodeVideoFrame( "
                                     "this : %p, "
                                     "[New SPS], "
                                     "mSpSize : %d "
                                     ")",
                                     this,
                                     mSpSize);
                        bChange = CheckVideoSize();
                    }
                }

                if (nalu->GetNaluType() == VFT_PPS) {
                    if ((mPpsSize != sliceLenOriginal) || (0 != memcmp(mpPps, sliceData, sliceLenOriginal))) {
                        if (mPpsSize < sliceLenOriginal) {
                            if (mpPps) {
                                delete[] mpPps;
                                mpPps = NULL;
                            }
                            mpPps = new char[sliceLenOriginal];
                        }
                        mPpsSize = sliceLenOriginal;
                        memcpy(mpPps, sliceData, mPpsSize);

                        FileLevelLog("rtmpdump",
                                     KLog::LOG_MSG,
                                     "VideoHardDecoder::DecodeVideoFrame( "
                                     "this : %p, "
                                     "[New PPS], "
                                     "mPpsSize : %d "
                                     ")",
                                     this,
                                     mPpsSize);
                    }
                }
            }
        }
    }

    mRuningMutex.lock();
    if (bChange) {
        DestroyContext();
        CreateContext();
    }

    OSStatus status = noErr;
    CMBlockBufferRef blockBuffer = NULL;
    status = CMBlockBufferCreateWithMemoryBlock(
        kCFAllocatorDefault,
        (void *)mVideoDecodeFrame.GetBuffer(),
        mVideoDecodeFrame.mBufferLen,
        kCFAllocatorNull,
        NULL,
        0,
        mVideoDecodeFrame.mBufferLen,
        0,
        &blockBuffer);
    if (status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {mVideoDecodeFrame.mBufferLen};
        //        CMSampleTimingInfo timingInfo = {CMTimeMake(0, 0), CMTimeMake(ts, 15), CMTimeMake(ts, 15)};
        status = CMSampleBufferCreateReady(
            kCFAllocatorDefault,
            blockBuffer,
            mFormatDesc,
            1,
            0,
            NULL,
            1,
            sampleSizeArray,
            &sampleBuffer);

        if (status == kCMBlockBufferNoErr) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;

            DecodeItem item;
            item.ts = pts;
            item.decoder = this;

            status = VTDecompressionSessionDecodeFrame(
                mSession,
                sampleBuffer,
                flags,
                &item,
                &flagOut);

            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoHardDecoder::DecodeVideoFrame( "
                         "this : %p, "
                         "[Decode Video Result], "
                         "status : %d, "
                         "item : %p, "
                         "ts : %u "
                         ")",
                         this,
                         status,
                         &item,
                         pts);

            if (status != noErr || mbError) {
                DestroyContext();
                CreateContext();
                mbError = false;
            }

            CFRelease(sampleBuffer);
        }

        CFRelease(blockBuffer);
    }

    mRuningMutex.unlock();
}

void VideoHardDecoder::ReleaseVideoFrame(void *frame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoHardDecoder::ReleaseVideoFrame( "
                 "this : %p, "
                 "frame : %p "
                 ")",
                 this,
                 frame);

    CVImageBufferRef imageBuffer = (CVImageBufferRef)frame;
    CFRelease(imageBuffer);
}

void VideoHardDecoder::StartDropFrame() {
}

void VideoHardDecoder::ClearVideoFrame() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::ClearVideoFrame( "
                 "this : %p "
                 ")",
                 this);
}

// 硬解码callback
void VideoHardDecoder::DecodeOutputCallback(
    void *decompressionOutputRefCon,
    void *sourceFrameRefCon,
    OSStatus status,
    VTDecodeInfoFlags infoFlags,
    CVImageBufferRef imageBuffer,
    CMTime presentationTS,
    CMTime presentationDuration) {

    Float64 ptTimestamp = CMTimeGetSeconds(presentationTS);
    Float64 ptDuration = CMTimeGetSeconds(presentationDuration);

    DecodeItem *item = NULL;
    int64_t ts = 0x7FFFFFFFFFFFFFFF;
    if (sourceFrameRefCon != NULL) {
        item = (DecodeItem *)sourceFrameRefCon;
        ts = item->ts;
    }

    if (status == noErr) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "VideoHardDecoder::DecodeOutputCallback( "
                     "[Decode Video Success], "
                     "item : %p, "
                     "ts : %lld "
                     ")",
                     item,
                     ts);

        if (imageBuffer != NULL) {
            if (NULL != item && item->decoder) {
                CFRetain(imageBuffer);
                item->decoder->DecodeCallbackProc(imageBuffer, item->ts);
            }
        }
    } else {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoHardDecoder::DecodeOutputCallback( "
                     "[Decode Video Error], "
                     "status : %d, "
                     "item : %p, "
                     "ts : %u "
                     ")",
                     status,
                     item,
                     ts);
        if (NULL != item && item->decoder) {
            if (NULL != item && item->decoder) {
                item->decoder->DecodeCallbackProc(NULL, item->ts, false);
            }
        }
    }
}

// 硬解码回调
void VideoHardDecoder::DecodeCallbackProc(void *frame, int64_t ts, bool bFlag) {
    // 不用锁, 因为DecodeOutputCallback是VTDecompressionSessionDecodeFrame的同步回调(不同线程)
    mbError = !bFlag;
    if (NULL != mpCallback) {
        if (bFlag) {
            mpCallback->OnDecodeVideoFrame(this, frame, ts);
        } else {
            //            mpCallback->OnDecodeVideoError(this);
        }
    }

    //        CIImage* ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    //
    //        CIContext *context = [CIContext contextWithOptions:nil];
    //        CGImageRef cgiimage = [context createCGImage:ciImage fromRect:ciImage.extent];
    //        UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
    //
    //        NSString* imageName = [NSString stringWithFormat:@"%.7d.png", item->ts];
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
    //        NSData* dataImage = UIImagePNGRepresentation(uiImage);
    //        [dataImage writeToFile:filePath atomically:YES];
}

void VideoHardDecoder::ResetParam() {
    if (mpSps) {
        delete[] mpSps;
        mpSps = NULL;
    }

    if (mpPps) {
        delete[] mpPps;
        mpPps = NULL;
    }

    mWidth = 0;
    mHeight = 0;
    mNaluHeaderSize = 0;
}

bool VideoHardDecoder::CreateContext() {
    bool bFlag = false;
    OSStatus status = noErr;

    mRuningMutex.lock();

    if (NULL == mSession) {
        // 初始化Video格式
        
        if ( mVpsSize > 0 && mpVps ) {
            const int parameterSetCount = 3;
            const uint8_t *const parameterSetPointers[parameterSetCount] = {(const uint8_t *)mpVps, (const uint8_t *)mpSps, (const uint8_t *)mpPps};
            const size_t parameterSetSizes[parameterSetCount] = {mVpsSize, mSpSize, mPpsSize};
            if (@available(iOS 11.0, *)) {
                status = CMVideoFormatDescriptionCreateFromHEVCParameterSets(
                                                                             kCFAllocatorDefault,
                                                                             parameterSetCount,
                                                                             parameterSetPointers,
                                                                             parameterSetSizes,
                                                                             mNaluHeaderSize,
                                                                             NULL,
                                                                             &mFormatDesc);
            } else {
                // Fallback on earlier versions
                status = kUnknownType;
            }
        } else {
            const int parameterSetCount = 2;
            const uint8_t *const parameterSetPointers[parameterSetCount] = {(const uint8_t *)mpSps, (const uint8_t *)mpPps};
            const size_t parameterSetSizes[parameterSetCount] = {mSpSize, mPpsSize};
            status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
                kCFAllocatorDefault,
                parameterSetCount,
                parameterSetPointers,
                parameterSetSizes,
                mNaluHeaderSize,
                &mFormatDesc);
        }

        if (status == noErr) {
            // 初始化回调参数
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = DecodeOutputCallback;
            callBackRecord.decompressionOutputRefCon = this;

            // 初始化输出视频格式参数
            const int iFormatType = kCVPixelFormatType_32BGRA;
            CFNumberRef formatType = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &iFormatType);
            // 组成key及value
            const int itemCount = 1;
            const void *key[itemCount] = {kCVPixelBufferPixelFormatTypeKey};
            const void *value[itemCount] = {formatType};
            // 生成参数
            CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, key, value, itemCount, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

            // 创建解码器
            status = VTDecompressionSessionCreate(
                kCFAllocatorDefault,
                mFormatDesc,
                NULL,
                attributes,
                &callBackRecord,
                &mSession);

            // 回收参数
            CFRelease(attributes);
            CFRelease(formatType);

            bFlag = (status == noErr);
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::CreateContext( this : %p, [%s], mSession : %p, status : %d )", this, bFlag ? "Success" : "Fail", mSession, status);

    mRuningMutex.unlock();

    return bFlag;
}

void VideoHardDecoder::DestroyContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::DestroyContext( this : %p, mSession : %p )", this, mSession);

    mRuningMutex.lock();

    if (mSession) {
        VTDecompressionSessionInvalidate(mSession);
        CFRelease(mSession);
        mSession = NULL;
    }

    if (mFormatDesc != nil) {
        CFRelease(mFormatDesc);
        mFormatDesc = NULL;
    }

    mRuningMutex.unlock();
}

char *VideoHardDecoder::FindSlice(char *start, int size, int &sliceSize) {
    static const char sliceStartCode[] = {0x00, 0x00, 0x01};

    sliceSize = 0;
    char *slice = NULL;

    for (int i = 0; i < size; i++) {
        if (i + sizeof(sliceStartCode) < size &&
            memcmp(start + i, sliceStartCode, sizeof(sliceStartCode)) == 0) {
            sliceSize = sizeof(sliceStartCode);
            slice = start + i;
            break;
        }
    }

    return slice;
}

bool VideoHardDecoder::CheckVideoSize() {
    bool bFlag = false;

    if ( mVpsSize > 0 && mpVps ) {
        bFlag = CheckVideoSizeHEVC();
    } else {
        bFlag = CheckVideoSizeH264();
    }
    return bFlag;
}

bool VideoHardDecoder::CheckVideoSizeH264() {
    bool bFlag = false;
    
    unsigned char *sliceData = (unsigned char *)mpSps + 1;
    int sliceLenOriginal = mSpSize - 1;

    unsigned int startBit = 0;
    int profile_idc = U(8, (unsigned char *)sliceData, startBit);
    int constraint_set0_flag = U(1, (unsigned char *)sliceData, startBit);
    int constraint_set1_flag = U(1, (unsigned char *)sliceData, startBit);
    int constraint_set2_flag = U(1, (unsigned char *)sliceData, startBit);
    int constraint_set3_flag = U(1, (unsigned char *)sliceData, startBit);
    int reserved_zero_4bits = U(4, (unsigned char *)sliceData, startBit);
    int level_idc = U(8, (unsigned char *)sliceData, startBit);
    int seq_parameter_set_id = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);

    int chroma_format_idc = -1;
    if (profile_idc == 100 || profile_idc == 110 ||
        profile_idc == 122 || profile_idc == 244 || profile_idc == 44 ||
        profile_idc == 83 || profile_idc == 86 || profile_idc == 118 ||
        profile_idc == 128) {
        chroma_format_idc = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        if (chroma_format_idc == 3) {
            int residual_colour_transform_flag = U(1, (unsigned char *)sliceData, startBit);
        }
        int bit_depth_luma_minus8 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int bit_depth_chroma_minus8 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int qpprime_y_zero_transform_bypass_flag = U(1, (unsigned char *)sliceData, startBit);
        int seq_scaling_matrix_present_flag = U(1, (unsigned char *)sliceData, startBit);

        int seq_scaling_list_present_flag[8];
        if (seq_scaling_matrix_present_flag) {
            for (int i = 0; i < 8; i++) {
                seq_scaling_list_present_flag[i] = U(1, (unsigned char *)sliceData, startBit);
            }
        }
    }
    int log2_max_frame_num_minus4 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int pic_order_cnt_type = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    if (pic_order_cnt_type == 0) {
        int log2_max_pic_order_cnt_lsb_minus4 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    } else if (pic_order_cnt_type == 1) {
        int delta_pic_order_always_zero_flag = U(1, (unsigned char *)sliceData, startBit);
        int offset_for_non_ref_pic = SE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int offset_for_top_to_bottom_field = SE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int num_ref_frames_in_pic_order_cnt_cycle = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);

        SE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    }
    int num_ref_frames = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int gaps_in_frame_num_value_allowed_flag = U(1, (unsigned char *)sliceData, startBit);
    int pic_width_in_mbs_minus1 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int pic_height_in_map_units_minus1 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int frame_mbs_only_flag = U(1, (unsigned char *)sliceData, startBit);
    
    int width = (pic_width_in_mbs_minus1 + 1) * 16;
    int height = (pic_height_in_map_units_minus1 + 1) * 16;
    height *= (2 - frame_mbs_only_flag);

    if ( (mWidth == 0 && mHeight == 0) ||
        ((mWidth != 0 && mHeight != 0) && (mWidth != width || mHeight != height))
        ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoHardDecoder::CheckVideoSizeH264( "
                     "this : %p, "
                     "[New Video Coded Size], "
                     "mSpSize : %d, "
                     "profile_idc : %d, "
                     "[%dx%d] => [%dx%d] "
                     ")",
                     this,
                     mSpSize,
                     profile_idc,
                     mWidth,
                     mHeight,
                     width,
                     height);
        bFlag = true;
    }

    mWidth = width;
    mHeight = height;
    int displayWidth = width;
    int displayHeight = height;
    
    if (!frame_mbs_only_flag) {
        int mb_adaptive_frame_field_flag = U(1, (unsigned char *)sliceData, startBit);
    }
    int direct_8x8_inference_flag = U(1, (unsigned char *)sliceData, startBit);
    int frame_cropping_flag = U(1, (unsigned char *)sliceData, startBit);
    if (frame_cropping_flag) {
        int frame_crop_left_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_right_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_top_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_bottom_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        
        int crop_unit_x = 0;
        int crop_unit_y = 0;
        
        if ( chroma_format_idc == -1 ) {
            // baseline
            crop_unit_x = 2;
            crop_unit_y = 2;
        } else if (0 == chroma_format_idc) {
            // monochrome
            crop_unit_x = 1;
            crop_unit_y = 2 - frame_mbs_only_flag;
        } else if (1 == chroma_format_idc) {
            // 4:2:0
            crop_unit_x = 2;
            crop_unit_y = 2 * (2 - frame_mbs_only_flag);
        } else if (2 == chroma_format_idc) {
            // 4:2:2
            crop_unit_x = 2;
            crop_unit_y = 2 - frame_mbs_only_flag;
        } else {
            // 4:4:4
            crop_unit_x = 1;
            crop_unit_y = 2 - frame_mbs_only_flag;
        }

        displayWidth = mWidth - crop_unit_x * (frame_crop_left_offset + frame_crop_right_offset);
        displayHeight = mHeight - crop_unit_y * (frame_crop_top_offset + frame_crop_bottom_offset);
        
        if (bFlag) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoHardDecoder::CheckVideoSizeH264( "
                         "this : %p, "
                         "[New Video Display Size], "
                         "[%dx%d] => [%dx%d], "
                         "chroma_format_idc : %d, "
                         "frame_crop_left_offset : %d, "
                         "frame_crop_right_offset : %d, "
                         "frame_crop_top_offset : %d, "
                         "frame_crop_bottom_offset : %d "
                         ")",
                         this,
                         mWidth,
                         mHeight,
                         displayWidth,
                         displayHeight,
                         chroma_format_idc,
                         frame_crop_left_offset,
                         frame_crop_right_offset,
                         frame_crop_top_offset,
                         frame_crop_bottom_offset
                         );
        }
    } else {
        if (bFlag) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoHardDecoder::CheckVideoSizeH264( "
                         "this : %p, "
                         "[New Video Display Size], "
                         "[%dx%d] => [%dx%d] "
                         ")",
                         this,
                         mWidth,
                         mHeight,
                         displayWidth,
                         displayHeight
                         );
        }
    }
    
    if (bFlag && mpCallback) {
        mpCallback->OnDecodeVideoChangeSize(this, displayWidth, displayHeight);
    }
    
    return bFlag;
}

bool VideoHardDecoder::CheckVideoSizeHEVC() {
    bool bFlag = false;
    
    unsigned char *sliceData = (unsigned char *)mpSps + 2;
    int sliceLenOriginal = mSpSize - 1;

    unsigned int startBit = 0;
    // VPS_ID - sps_video_parameter_set_id
    int vps_id = U(4, (unsigned char *)sliceData, startBit);
    
    int sps_max_sub_layers_minus1 = U(3, (unsigned char *)sliceData, startBit) + 1;
    int temporal_id_nested = U(1, (unsigned char *)sliceData, startBit);
    
    int profile_space               = U(2, (unsigned char *)sliceData, startBit);
    int tier_flag                   = U(1, (unsigned char *)sliceData, startBit);
    int profile_idc                 = U(5, (unsigned char *)sliceData, startBit);
    U(32, (unsigned char *)sliceData, startBit);
    U(4, (unsigned char *)sliceData, startBit);
    U(44, (unsigned char *)sliceData, startBit);
    int level_idc = U(8, (unsigned char *)sliceData, startBit);

    static const uint8_t HEVC_MAX_SUB_LAYERS = 7;
    uint8_t sub_layer_profile_present_flag[HEVC_MAX_SUB_LAYERS] = {0};
    uint8_t sub_layer_level_present_flag[HEVC_MAX_SUB_LAYERS] = {0};
    
    for (int i = 0; i < sps_max_sub_layers_minus1 - 1; i++) {
        sub_layer_profile_present_flag[i] = U(1, (unsigned char *)sliceData, startBit);
        sub_layer_level_present_flag[i]   = U(1, (unsigned char *)sliceData, startBit);
    }

    if (sps_max_sub_layers_minus1 - 1 > 0) {
        for (int i = sps_max_sub_layers_minus1 - 1; i < 8; i++) {
            // reserved_zero_2bits[i]
            U(2, (unsigned char *)sliceData, startBit);
        }
    }
    for (int i = 0; i < sps_max_sub_layers_minus1 - 1; i++) {
        if (sub_layer_profile_present_flag[i]) {
            /*
             * sub_layer_profile_space[i]                     u(2)
             * sub_layer_tier_flag[i]                         u(1)
             * sub_layer_profile_idc[i]                       u(5)
             * sub_layer_profile_compatibility_flag[i][0..31] u(32)
             * sub_layer_progressive_source_flag[i]           u(1)
             * sub_layer_interlaced_source_flag[i]            u(1)
             * sub_layer_non_packed_constraint_flag[i]        u(1)
             * sub_layer_frame_only_constraint_flag[i]        u(1)
             * sub_layer_reserved_zero_44bits[i]              u(44)
             */
            U(8, (unsigned char *)sliceData, startBit);
            U(32, (unsigned char *)sliceData, startBit);
            U(4, (unsigned char *)sliceData, startBit);
            U(44, (unsigned char *)sliceData, startBit);
        }

        if (sub_layer_level_present_flag[i]) {
            U(8, (unsigned char *)sliceData, startBit);
        }
    }
    
    // SPS_ID
    int sps_seq_parameter_set_id = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int chroma_format_idc = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    if (chroma_format_idc == 3) {
        int residual_colour_transform_flag = U(1, (unsigned char *)sliceData, startBit);
    }
    
    int pic_width_in_mbs_minus1 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    int pic_height_in_map_units_minus1 = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
    
    int width = (pic_width_in_mbs_minus1 + 1) * 16;
    int height = (pic_height_in_map_units_minus1 + 1) * 16;
    
    if ( (mWidth == 0 && mHeight == 0) ||
        ((mWidth != 0 && mHeight != 0) && (mWidth != width || mHeight != height))
        ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoHardDecoder::CheckVideoSizeHEVC( "
                     "this : %p, "
                     "[New Video Coded Size], "
                     "mSpSize : %d, "
                     "profile_idc : %d, "
                     "[%dx%d] => [%dx%d] "
                     ")",
                     this,
                     mSpSize,
                     profile_idc,
                     mWidth,
                     mHeight,
                     width,
                     height);
        bFlag = true;
    }

    mWidth = width;
    mHeight = height;
    
    int displayWidth = width;
    int displayHeight = height;
    
    int frame_cropping_flag = U(1, (unsigned char *)sliceData, startBit);
    if (frame_cropping_flag) {
        int frame_crop_left_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_right_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_top_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        int frame_crop_bottom_offset = UE((unsigned char *)sliceData, sliceLenOriginal, startBit);
        
        int crop_unit_x = 0;
        int crop_unit_y = 0;
        
//        if ( chroma_format_idc == -1 ) {
//            // baseline
//            crop_unit_x = 2;
//            crop_unit_y = 2;
//        } else if (0 == chroma_format_idc) {
//            // monochrome
//            crop_unit_x = 1;
//            crop_unit_y = 2 - frame_mbs_only_flag;
//        } else if (1 == chroma_format_idc) {
//            // 4:2:0
//            crop_unit_x = 2;
//            crop_unit_y = 2 * (2 - frame_mbs_only_flag);
//        } else if (2 == chroma_format_idc) {
//            // 4:2:2
//            crop_unit_x = 2;
//            crop_unit_y = 2 - frame_mbs_only_flag;
//        } else {
//            // 4:4:4
//            crop_unit_x = 1;
//            crop_unit_y = 2 - frame_mbs_only_flag;
//        }

        displayWidth = mWidth - crop_unit_x * (frame_crop_left_offset + frame_crop_right_offset);
        displayHeight = mHeight - crop_unit_y * (frame_crop_top_offset + frame_crop_bottom_offset);
        
        if (bFlag) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoHardDecoder::CheckVideoSizeHEVC( "
                         "this : %p, "
                         "[New Video Display Size], "
                         "[%dx%d] => [%dx%d], "
                         "chroma_format_idc : %d, "
                         "frame_crop_left_offset : %d, "
                         "frame_crop_right_offset : %d, "
                         "frame_crop_top_offset : %d, "
                         "frame_crop_bottom_offset : %d "
                         ")",
                         this,
                         mWidth,
                         mHeight,
                         displayWidth,
                         displayHeight,
                         chroma_format_idc,
                         frame_crop_left_offset,
                         frame_crop_right_offset,
                         frame_crop_top_offset,
                         frame_crop_bottom_offset
                         );
        }
    } else {
        if (bFlag) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoHardDecoder::CheckVideoSizeH264( "
                         "this : %p, "
                         "[New Video Display Size], "
                         "[%dx%d] => [%dx%d] "
                         ")",
                         this,
                         mWidth,
                         mHeight,
                         displayWidth,
                         displayHeight
                         );
        }
    }
        
    return bFlag;
}

}
