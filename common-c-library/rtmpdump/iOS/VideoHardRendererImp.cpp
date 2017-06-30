//
//  VideoRenderImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoHardRendererImp.h"
namespace coollive {
VideoHardRendererImp::VideoHardRendererImp(id<VideoHardRendererDelegate> _Nullable VideoHardRendererImp) {
    mpVideoHardRendererImp = VideoHardRendererImp;
}

VideoHardRendererImp::~VideoHardRendererImp() {
    
}

void VideoHardRendererImp::RenderVideoFrame(void* _Nonnull frame) {
    // 播放视频
    if( [mpVideoHardRendererImp respondsToSelector:@selector(renderVideoFrame:)] ) {
        CVPixelBufferRef buffer = (CVPixelBufferRef)frame;
        [mpVideoHardRendererImp renderVideoFrame:buffer];

    }

}
}
