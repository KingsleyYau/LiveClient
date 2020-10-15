//
//  AudioRendererImp.h
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AudioRendererImp_h
#define AudioRendererImp_h

#include <rtmpdump/IAudioRenderer.h>
#include <rtmpdump/audio/AudioFrame.h>

#include <common/list_lock.h>

#include <stdio.h>

#import <AVFoundation/AVFoundation.h>

using namespace coollive;
class AudioRendererImp : public AudioRenderer {
public:
    AudioRendererImp();
    ~AudioRendererImp();
    
    void RenderAudioFrame(void* _Nullable audioFrame);
    bool Start();
    void Stop();
    void Reset();
    
    bool GetMute();
    void SetMute(bool isMute);
    
    void SetPlaybackRate(float playBackRate);
    
private:
    bool Create(void *audioFrame = NULL);
    static void AudioQueueOutputCallback(
                                         void * __nullable                inUserData,
                                         AudioQueueRef _Nullable          inAQ,
                                         AudioQueueBufferRef _Nullable    inBuffer
                                         );
    
protected:
    AudioQueueRef _Nullable mAudioQueue;
    list_lock<AudioQueueBufferRef> mAudioBufferList;
    AudioStreamBasicDescription mAsbd;
    
    bool mIsMute;
    float mPlaybackRate;
    bool mPlaybackRateChange;
};

#endif /* AudioRendererImp_h */
