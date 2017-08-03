//
//  VideoRenderImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoRendererImp.h"
namespace coollive {
VideoRendererImp::VideoRendererImp(id<VideoRendererDelegate> _Nullable videoRendererImp) {
    mpVideoRendererImp = videoRendererImp;
}

VideoRendererImp::~VideoRendererImp() {
    
}

void VideoRendererImp::RenderVideoFrame(void* _Nonnull frame) {   
    VideoFrame* displayFrame = (VideoFrame *)frame;
    
    // 播放视频
    if( [mpVideoRendererImp respondsToSelector:@selector(renderVideoFrame:)] ) {
        CVPixelBufferRef buffer = CreatePixelBufferByRGBData(
                                                             (const unsigned char*)displayFrame->GetBuffer(),
                                                             displayFrame->mBufferLen,
                                                             displayFrame->mWidth,
                                                             displayFrame->mHeight
                                                             );
        
        [mpVideoRendererImp renderVideoFrame:buffer];

        CFRelease(buffer);
    }
}

CVPixelBufferRef VideoRendererImp::CreatePixelBufferByRGBData(const unsigned char* data, int size, int width, int height) {
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(
                                          kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);
    
    if ( result == kCVReturnSuccess ) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void* buffer = CVPixelBufferGetBaseAddress(pixelBuffer);
        memcpy(buffer, data, size);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
    
    return pixelBuffer;
}
}
