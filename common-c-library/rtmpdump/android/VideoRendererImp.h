//
//  VideoRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoRendererImp_h
#define VideoRendererImp_h

#include <stdio.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <rtmpdump/VideoFrame.h>
#include <rtmpdump/IVideoRenderer.h>

namespace coollive {
class VideoRendererImp : public VideoRenderer {
public:
	VideoRendererImp(jobject jniRenderer);
    ~VideoRendererImp();
    
    void RenderVideoFrame(void* frame);

private:
    jobject mJniRenderer;
    jbyteArray dataByteArray;
};
}
#endif /* VideoRendererImp_h */
