//
//  VideoRenderImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoHardRendererImp.h"

#include <common/KLog.h>

namespace coollive {
VideoHardRendererImp::VideoHardRendererImp(id<VideoHardRendererDelegate> VideoHardRendererImp) {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardRendererImp::VideoHardRendererImp( this : %p )", this);
    
    mpVideoHardRendererImp = VideoHardRendererImp;
}

VideoHardRendererImp::~VideoHardRendererImp() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardRendererImp::~VideoHardRendererImp( this : %p )", this);
}

void VideoHardRendererImp::RenderVideoFrame(void *frame) {
    // 播放视频
    if ([mpVideoHardRendererImp respondsToSelector:@selector(renderVideoFrame:)]) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)frame;
        [mpVideoHardRendererImp renderVideoFrame:pixelBuffer];
    }
}
}
