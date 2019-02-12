//
//  VideoRenderImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoRendererImp.h"

#include <common/KLog.h>

namespace coollive {
VideoRendererImp::VideoRendererImp(id<VideoRendererDelegate> videoRendererImp) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoRendererImp::VideoRendererImp( "
                 "this : %p "
                 ")",
                 this
                 );
    mpVideoRendererImp = videoRendererImp;
}

VideoRendererImp::~VideoRendererImp() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoRendererImp::~VideoRendererImp( "
                 "this : %p "
                 ")",
                 this
                 );
}

void VideoRendererImp::RenderVideoFrame(void *frame) {
    VideoFrame *displayFrame = (VideoFrame *)frame;

    // 播放视频
    if ([mpVideoRendererImp respondsToSelector:@selector(renderVideoFrame:)]) {
        CVPixelBufferRef buffer = CreatePixelBufferByRGBData(
            (const unsigned char *)displayFrame->GetBuffer(),
            displayFrame->mBufferLen,
            displayFrame->mWidth,
            displayFrame->mHeight);

        [mpVideoRendererImp renderVideoFrame:buffer];

        CFRelease(buffer);
    }
}

CVPixelBufferRef VideoRendererImp::CreatePixelBufferByRGBData(const unsigned char *data, int size, int width, int height) {
    NSDictionary *pixelAttributes = @{
        (id)kCVPixelBufferOpenGLESCompatibilityKey : @(YES),
    };

    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_32BGRA,
        (__bridge CFDictionaryRef)(pixelAttributes),
        &pixelBuffer);

    if (result == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        // 为字节对齐做处理
        size_t dataBytePerRow = width * 4;
        size_t bytePerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        size_t dataRowStart = 0;
        size_t bufferRowStart = 0;
        void *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        for(int rowIndex = 0; rowIndex < height; rowIndex++) {
            dataRowStart = rowIndex * dataBytePerRow;
            bufferRowStart = rowIndex * bytePerRow;
            memcpy((void *)((char *)buffer + bufferRowStart), (void *)((char *)data + dataRowStart), dataBytePerRow);
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }

    return pixelBuffer;
}
}
