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
    VideoHardDecoder* decoder;
    u_int32_t timestamp;
    
    _tagDecodeItem() {
        decoder = NULL;
        timestamp = 0;
    }
} DecodeItem;
    
VideoHardDecoder::VideoHardDecoder()
    :mRuningMutex(KMutex::MutexType_Recursive)
{
    FileLog("rtmpdump", "VideoHardDecoder::VideoHardDecoder( decoder : %p )", this);
    
    mpCallback = NULL;
    mSession = NULL;
    mFormatDesc = NULL;
    
    mpSps = NULL;
    mSpSize = 0;
    mpPps = NULL;
    mPpsSize = 0;
    mNaluHeaderSize = 0;
    
}

VideoHardDecoder::~VideoHardDecoder()
{
    FileLog("rtmpdump", "VideoHardDecoder::~VideoHardDecoder( decoder : %p )", this);
    
    DestroyContext();
    
    ResetParam();
}

bool VideoHardDecoder::Create(VideoDecoderCallback* callback)
{
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( this : %p )", this);
    
    bool result = false;
    if (NULL != callback) {
        mpCallback = callback;
        result = true;
    }
    
    ResetParam();
    
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( [Success], this : %p )", this);
    
    return result;
}

    
void VideoHardDecoder::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Pause( this : %p )", this);
    
    DestroyContext();
}
    
bool VideoHardDecoder::Reset() {
    bool bFlag = true;
    
    mRuningMutex.lock();
    if(
       mpSps != NULL &&
       mSpSize != 0 &&
       mpPps != NULL &&
       mPpsSize != 0 &&
       mNaluHeaderSize != 0
       ) {
        bFlag = CreateContext();
    }
    mRuningMutex.unlock();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardDecoder::Reset( "
                 "[%s], "
                 "this : %p "
                 ")",
                 bFlag?"Success":"Fail",
                 this
                 );
    
    return bFlag;
}

void VideoHardDecoder::ResetStream() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::ResetStream( this : %p )", this);
}
    
void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::DecodeVideoKeyFrame( "
                 "this : %p, "
                 "sps : %p, "
                 "sps_size : %d, "
                 "pps : %p, "
                 "pps_size : %d, "
                 "nalUnitHeaderLength : %d "
                 ")",
                 this,
                 sps,
                 sps_size,
                 pps,
                 pps_size,
                 nalUnitHeaderLength
                 );
    
    DestroyContext();
    
    mRuningMutex.lock();
    
    // 重新设置解码器变量
    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
    }
    
    mSpSize = sps_size;
    mpSps = new char[mSpSize];
    memcpy(mpSps, sps, mSpSize);
    
    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
    }

    mPpsSize = pps_size;
    mpPps = new char[mPpsSize];
    memcpy(mpPps, pps, mPpsSize);
    
    mNaluHeaderSize = nalUnitHeaderLength;

    if(
       mpSps != NULL &&
       mSpSize != 0 &&
       mpPps != NULL &&
       mPpsSize != 0 &&
       mNaluHeaderSize != 0
       ) {
        CreateContext();
    }
    
    mRuningMutex.unlock();
}

void VideoHardDecoder::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
    // 重置解码Buffer
    mVideoDecodeFrame.ResetFrame();
    
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bool bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if( bFlag && naluArraySize > 0 ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_STAT,
                     "VideoHardDecoder::DecodeVideoFrame( "
                     "[Got Nalu Array], "
                     "timestamp : %u, "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
                     timestamp,
                     size,
                     naluArraySize
                     );
        
        int naluIndex = 0;
        while( naluIndex < naluArraySize ) {
            Nalu* nalu = naluArray + naluIndex;
            naluIndex++;
            
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardDecoder::DecodeVideoFrame( "
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType()
                         );
            
            Slice* sliceArray = NULL;
            int sliceArraySize = 0;
            int sliceIndex = 0;
            
            if( nalu->GetNaluType() == VFT_NOTIDR || nalu->GetNaluType() == VFT_IDR ) {
                nalu->GetSlices(&sliceArray, sliceArraySize);
                FileLevelLog("rtmpdump",
                             KLog::LOG_STAT,
                             "VideoHardDecoder::DecodeVideoFrame( "
                             "[Got Slice Array], "
                             "sliceArraySize : %d "
                             ")",
                             sliceArraySize
                             );
                while( sliceIndex < sliceArraySize ) {
                    Slice* slice = sliceArray + sliceIndex;
                    sliceIndex++;
                    
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_STAT,
                                 "VideoHardDecoder::DecodeVideoFrame( "
                                 "[Got Slice], "
                                 "sliceSize : %d, "
                                 "isFirstSlice : %d "
                                 ")",
                                 slice->GetSliceSize(),
                                 slice->IsFirstSlice()
                                 );
                    
                    int sliceLen = CFSwapInt32HostToBig(slice->GetSliceSize());
                    mVideoDecodeFrame.AddBuffer((const unsigned char *)&sliceLen, sizeof(sliceLen));
                    mVideoDecodeFrame.AddBuffer((const unsigned char *)slice->GetSlice(), slice->GetSliceSize());
                }
            }
        }
    }
    
    mRuningMutex.lock();
    
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
                                                &blockBuffer
                                                );
    if( status == kCMBlockBufferNoErr ) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {mVideoDecodeFrame.mBufferLen};
        status = CMSampleBufferCreateReady(
                                           kCFAllocatorDefault,
                                           blockBuffer,
                                           mFormatDesc,
                                           1,
                                           0,
                                           NULL,
                                           1,
                                           sampleSizeArray,
                                           &sampleBuffer
                                           );
        
        if( status == kCMBlockBufferNoErr ) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            
            DecodeItem item;
            item.timestamp = timestamp;
            item.decoder = this;
            
            status = VTDecompressionSessionDecodeFrame(
                                                       mSession,
                                                       sampleBuffer,
                                                       flags,
                                                       &item,
                                                       &flagOut
                                                       );
            
            CFRelease(sampleBuffer);
        }
        
        CFRelease(blockBuffer);
    }
    
    mRuningMutex.unlock();
}

void VideoHardDecoder::ReleaseVideoFrame(void* frame) {
    CVImageBufferRef imageBuffer = (CVImageBufferRef)frame;
    CFRelease(imageBuffer);
}
    
void VideoHardDecoder::StartDropFrame() {
    
}
    
// 硬解码callback
void VideoHardDecoder::DecodeOutputCallback (
                                         void* decompressionOutputRefCon,
                                         void* sourceFrameRefCon,
                                         OSStatus status,
                                         VTDecodeInfoFlags infoFlags,
                                         CVImageBufferRef imageBuffer,
                                         CMTime presentationTimeStamp,
                                         CMTime presentationDuration
                                         )
{
    if( status == noErr ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_STAT,
                     "VideoHardDecoder::DecodeOutputCallback( "
                     "[Decode Video Success] "
                     ")"
                     );
        
        if( imageBuffer != NULL && sourceFrameRefCon != NULL ) {
            DecodeItem* item = (DecodeItem*)sourceFrameRefCon;
            if (NULL != item
                && item->decoder) {
                CFRetain(imageBuffer);
                
                item->decoder->DecodeCallbackProc(imageBuffer, item->timestamp);
            }
        }
    } else {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoHardDecoder::DecodeOutputCallback( "
                     "[Decode Video Error], "
                     "status : %d "
                     ")",
                     status
                     );
    }
}

// 硬解码回调
void VideoHardDecoder::DecodeCallbackProc(void* frame, u_int32_t timestamp)
{
    if (NULL != mpCallback) {
        mpCallback->OnDecodeVideoFrame(this, frame, timestamp);
    }
    
//        CIImage* ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
//
//        CIContext *context = [CIContext contextWithOptions:nil];
//        CGImageRef cgiimage = [context createCGImage:ciImage fromRect:ciImage.extent];
//        UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
//
//        NSString* imageName = [NSString stringWithFormat:@"%.7d.png", item->timestamp];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
//        NSData* dataImage = UIImagePNGRepresentation(uiImage);
//        [dataImage writeToFile:filePath atomically:YES];
}

void VideoHardDecoder::ResetParam() {
    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
    }
    
    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
    }
    
    mNaluHeaderSize = 0;
}
    
bool VideoHardDecoder::CreateContext() {
    bool bFlag = false;
    OSStatus status = noErr;
    
    mRuningMutex.lock();
    
    if (NULL == mSession) {
        // 初始化Video格式
        const int parameterSetCount = 2;
        const uint8_t* const parameterSetPointers[parameterSetCount] = {(const uint8_t*)mpSps, (const uint8_t*)mpPps};
        const size_t parameterSetSizes[parameterSetCount] = {mSpSize, mPpsSize};
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
                                                                     kCFAllocatorDefault,
                                                                     parameterSetCount,
                                                                     parameterSetPointers,
                                                                     parameterSetSizes,
                                                                     mNaluHeaderSize,
                                                                     &mFormatDesc
                                                                     );
        
        if( status == noErr ) {
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
                                                  &mSession
                                                  );
            
            // 回收参数
            CFRelease(attributes);
            CFRelease(formatType);
            
            bFlag = (status == noErr);
        }
    }

    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::CreateContext( [%s], this : %p, mSession : %p, status : %d )", bFlag?"Success":"Fail", this, mSession, status);
    
    mRuningMutex.unlock();
    
    return bFlag;
}

void VideoHardDecoder::DestroyContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::DestroyContext( this : %p, mSession : %p )", this, mSession);
    
    mRuningMutex.lock();
    
    if( mSession ) {
        VTDecompressionSessionInvalidate(mSession);
        CFRelease(mSession);
        mSession = NULL;
    }
    
    if( mFormatDesc != nil ) {
        CFRelease(mFormatDesc);
        mFormatDesc = NULL;
    }
    
    mRuningMutex.unlock();
}
    
char* VideoHardDecoder::FindSlice(char* start, int size, int& sliceSize) {
    static const char sliceStartCode[] = {0x00, 0x00, 0x01};
    
    sliceSize = 0;
    char* slice = NULL;
    
    for(int i = 0; i < size; i++) {
        if( i + sizeof(sliceStartCode) < size &&
           memcmp(start + i, sliceStartCode, sizeof(sliceStartCode)) == 0 ) {
            sliceSize = sizeof(sliceStartCode);
            slice = start + i;
            break;
        }
    }
    
    return slice;
}
}
