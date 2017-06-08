//
//  VideoHardDecoder.cpp
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//

#include "VideoHardDecoder.h"
#include <rtmpdump/RtmpPlayer.h>

VideoHardDecoder::VideoHardDecoder()
{
    mpPlayer = NULL;
    mSession = NULL;
    mFormatDesc = NULL;
}

VideoHardDecoder::~VideoHardDecoder()
{
    
}

bool VideoHardDecoder::Create(RtmpPlayer* player)
{
    bool result = false;
    if (NULL != player) {
        mpPlayer = player;
        result = true;
    }
    return result;
}

void VideoHardDecoder::Destroy()
{

}

void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength)
{
    if (NULL == mSession) {
        OSStatus status;

        // 初始化Video格式
        const int parameterSetCount = 2;
        const uint8_t* const parameterSetPointers[parameterSetCount] = {(const uint8_t*)sps, (const uint8_t*)pps};
        const size_t parameterSetSizes[parameterSetCount] = {sps_size, pps_size};
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
                                                                     kCFAllocatorDefault,
                                                                     parameterSetCount,
                                                                     parameterSetPointers,
                                                                     parameterSetSizes,
                                                                     nalUnitHeaderLength,
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
        }
    }
}

typedef struct _tagDecodeItem {
    VideoHardDecoder* decoder;
    u_int32_t timestamp;
    
    _tagDecodeItem() {
        decoder = NULL;
        timestamp = 0;
    }
} DecodeItem;

void VideoHardDecoder::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type)
{
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
    if( status == noErr
       && imageBuffer != NULL
       && NULL != sourceFrameRefCon )
    {
        // 放到播放队列
        DecodeItem* item = (DecodeItem*)sourceFrameRefCon;
        if (NULL != item
            && item->decoder)
        {
            CFRetain(imageBuffer);
            item->decoder->DecodeCallbackProc(imageBuffer, item->timestamp);
        }
    }
}

// 硬解码回调
void VideoHardDecoder::DecodeCallbackProc(void* frame, u_int32_t timestamp)
{
    if (NULL != mpPlayer) {
        mpPlayer->PushVideoFrame(frame, timestamp);
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

