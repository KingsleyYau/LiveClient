//
//  VideoRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoHardRendererImp_h
#define VideoHardRendererImp_h

#include <rtmpdump/IVideoRenderer.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <stdio.h>

namespace coollive {
class VideoHardRendererImp : public VideoRenderer {
public:
	VideoHardRendererImp(jobject jniRenderer);
    ~VideoHardRendererImp();
    
    void RenderVideoFrame(void* frame);
    
private:
    void DrawBitmap(char* data, int size, int width, int height);

private:
    jobject mJniRenderer;
    jbyteArray dataByteArray;
};
}
#endif /* VideoHardRendererImp_h */
