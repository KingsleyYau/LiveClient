//
//  VideoHardDecoder.cpp
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//

#include "VideoHardDecoder.h"

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
{
    FileLog("rtmpdump", "VideoHardDecoder::VideoHardDecoder( decoder : %p )", this);
    
    mpCallback = NULL;
    mSession = NULL;
    mFormatDesc = NULL;
    
    mpSps = NULL;
    mSpSize = 0;
    mpPps = NULL;
    mPpsSize = 0;
    mNalUnitHeaderLength = 0;
    
}

VideoHardDecoder::~VideoHardDecoder()
{
    FileLog("rtmpdump", "VideoHardDecoder::~VideoHardDecoder( decoder : %p )", this);
    
    Pause();
    
    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
    }
    
    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
    }
}

bool VideoHardDecoder::Create(VideoDecoderCallback* callback)
{
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( this : %p )", this);
    
    bool result = false;
    if (NULL != callback) {
        mpCallback = callback;
        result = true;
    }
    
    DestroyContext();
    
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Create( [Finish], this : %p )", this);
    
    return result;
}

    
void VideoHardDecoder::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::Pause( this : %p )", this);
    
    DestroyContext();
}
    
void VideoHardDecoder::Reset() {
    bool bFlag = true;
    
    bFlag = CreateContext();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardDecoder::Reset( "
                 "this : %p, "
                 "bFlag : %s "
                 ")",
                 this,
                 bFlag?"true":"false"
                 );
}

void VideoHardDecoder::ResetStream() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::ResetStream( this : %p )", this);
}
    
void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
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
    
    // 重新设置解码器变量
    mSpSize = sps_size;
    if( mpSps ) {
        delete[] mpSps;
    }
    mpSps = new char[mSpSize];
    memcpy(mpSps, sps, mSpSize);

    mPpsSize = pps_size;
    if( mpPps ) {
        delete[] mpPps;
    }
    mpPps = new char[mPpsSize];
    memcpy(mpPps, pps, mPpsSize);
    
    mNalUnitHeaderLength = nalUnitHeaderLength;

    CreateContext();
}

void VideoHardDecoder::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
    OSStatus status = noErr;
    CMBlockBufferRef blockBuffer = NULL;
    status = CMBlockBufferCreateWithMemoryBlock(
                                                kCFAllocatorDefault,
                                                (void *)data,
                                                size,
                                                kCFAllocatorNull,
                                                NULL,
                                                0,
                                                size,
                                                0,
                                                &blockBuffer
                                                );
    if( status == kCMBlockBufferNoErr ) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {size};
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
                     "[Decode Error], "
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
    
bool VideoHardDecoder::CreateContext() {
    bool bFlag = true;
    OSStatus status = noErr;
    
    if(
       mpSps != NULL &&
       mSpSize != 0 &&
       mpPps != NULL &&
       mPpsSize != 0 &&
       mNalUnitHeaderLength != 0
       ) {
        if (NULL == mSession) {
            bFlag = false;
            
            // 初始化Video格式
            const int parameterSetCount = 2;
            const uint8_t* const parameterSetPointers[parameterSetCount] = {(const uint8_t*)mpSps, (const uint8_t*)mpPps};
            const size_t parameterSetSizes[parameterSetCount] = {mSpSize, mPpsSize};
            status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
                                                                         kCFAllocatorDefault,
                                                                         parameterSetCount,
                                                                         parameterSetPointers,
                                                                         parameterSetSizes,
                                                                         mNalUnitHeaderLength,
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
    }

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::CreateContext( [%s], this : %p, mSession : %p, status : %d )", bFlag?"Success":"Fail", this, mSession, status);
    
    return bFlag;
}

void VideoHardDecoder::DestroyContext() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardDecoder::DestroyContext( this : %p, mSession : %p )", this, mSession);
    
    if( mSession ) {
        VTDecompressionSessionInvalidate(mSession);
        CFRelease(mSession);
        mSession = NULL;
    }
}
}
