//
//  VideoRenderImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoRenderImp_h
#define VideoRenderImp_h

#include <stdio.h>

#include <rtmpdump/VideoFrame.h>
#include <rtmpdump/IVideoRenderer.h>

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol VideoRendererDelegate <NSObject>
@optional
- (void)renderVideoFrame:(CVPixelBufferRef _Nonnull)frame;
@end

namespace coollive {
class VideoRendererImp : public VideoRenderer {
public:
    VideoRendererImp(id<VideoRendererDelegate> _Nullable videoRendererImp);
    
    ~VideoRendererImp();
    
    void RenderVideoFrame(void* _Nonnull frame);
   
private:
    VideoFrame mRendererVideoFrame;
    
private:
    CVPixelBufferRef _Nullable CreatePixelBufferByRGBData(const unsigned char* _Nonnull data, int size, int width, int height);
    
private:
    __weak typeof(id<VideoRendererDelegate>) _Nullable mpVideoRendererImp;
    
};
}
#endif /* VideoRenderImp_h */
