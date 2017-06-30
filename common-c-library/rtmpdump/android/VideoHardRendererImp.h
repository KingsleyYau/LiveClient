//
//  VideoRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoHardRendererImp_h
#define VideoHardRendererImp_h

#include <stdio.h>

#include <rtmpdump/android/JniGobalFunc.h>

#include <rtmpdump/VideoFrame.h>
#include <rtmpdump/IVideoRenderer.h>

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
