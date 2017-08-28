//
//  VideoRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoRendererImp_h
#define VideoRendererImp_h

#include <rtmpdump/IVideoRenderer.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <stdio.h>

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
