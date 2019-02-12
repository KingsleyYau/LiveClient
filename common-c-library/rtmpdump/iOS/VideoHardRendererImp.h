//
//  VideoRenderImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoHardRenderImp_h
#define VideoHardRenderImp_h

#include <stdio.h>

#include <rtmpdump/IVideoRenderer.h>

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol VideoHardRendererDelegate <NSObject>
@optional
- (void)renderVideoFrame:(CVPixelBufferRef)frame;
@end

namespace coollive {
class VideoHardRendererImp : public VideoRenderer {
  public:
    VideoHardRendererImp(id<VideoHardRendererDelegate> videoHardRendererImp);
    ~VideoHardRendererImp();

    void RenderVideoFrame(void *frame);

  private:
    __weak typeof(id<VideoHardRendererDelegate>) mpVideoHardRendererImp;
};
}
#endif /* VideoHardRenderImp_h */
