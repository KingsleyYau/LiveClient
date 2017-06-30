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

#import <AVFoundation/AVFoundation.h>

#include <rtmpdump/IAudioRenderer.h>
#include <rtmpdump/AudioFrame.h>
using namespace coollive;

#include <common/list_lock.h>

class AudioRendererImp : public AudioRenderer {
public:
    AudioRendererImp();
    ~AudioRendererImp();
    
    void RenderAudioFrame(void* _Nullable audioFrame);
    void Reset();
    
private:
    bool Create();
    static void AudioQueueOutputCallback(
                                         void * __nullable                inUserData,
                                         AudioQueueRef _Nullable          inAQ,
                                         AudioQueueBufferRef _Nullable    inBuffer
                                         );
    
protected:
    AudioQueueRef _Nullable mAudioQueue;
    list_lock<AudioQueueBufferRef> mAudioBufferList;
};

#endif /* AudioRendererImp_h */
