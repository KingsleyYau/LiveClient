//
//  AudioRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AudioRendererImp_h
#define AudioRendererImp_h

#include <stdio.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <rtmpdump/IAudioRenderer.h>

namespace coollive {
class AudioRendererImp : public AudioRenderer {
public:
    AudioRendererImp(jobject jniRenderer);
    ~AudioRendererImp();
    
    void RenderAudioFrame(void* frame);
    bool Start();
    void Stop();
    void Reset();

private:
    jobject mJniRenderer;
    jmethodID mJniRendererMethodID;
    jbyteArray dataByteArray;
};
}
#endif /* AudioRenderImp_h */
