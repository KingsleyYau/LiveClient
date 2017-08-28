//
//  AudioHardEncoder.h
//  RtmpClient
//
//  Created by Max on 2017/7/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AudioHardEncoder_h
#define AudioHardEncoder_h

#include <stdio.h>

#include <common/KMutex.h>

#include <rtmpdump/IEncoder.h>

#include <rtmpdump/audio/AudioFrame.h>
#include <rtmpdump/audio/AudioMuxer.h>

#include <CoreFoundation/CoreFoundation.h>
#include <AVFoundation/AVFoundation.h>

namespace coollive {
class AudioHardEncoder : public AudioEncoder {
public:
    AudioHardEncoder();
    virtual ~AudioHardEncoder();
    
public:
    bool Create(int sampleRate, int channelsPerFrame, int bitPerSample);
    void SetCallback(AudioEncoderCallback* callback);
    bool Reset();
    void Pause();
    void EncodeAudioFrame(void* data, int size, void* frame);
    
private:
    static OSStatus inInputDataProc(AudioConverterRef inAudioConverter,
                                    UInt32 *ioNumberDataPackets,
                                    AudioBufferList *ioData,
                                    AudioStreamPacketDescription **outDataPacketDescription,
                                    void *inUserData
                                    );
        
private:
    bool CreateContext(CMSampleBufferRef sampleBuffer);
    void DestroyContext();
    
private:
    AudioEncoderCallback* mpCallback;
    
    AudioFrameFormat mFormat;
    AudioFrameSoundRate mSoundRate;
    AudioFrameSoundSize mSoundSize;
    AudioFrameSoundType mSoundType;
    
    dispatch_queue_t mAudioEncodeQueue;
    AudioConverterRef mAudioConverter;
    AudioBuffer mAudioPCMBuffer;
    AudioBuffer mAudioAACBuffer;
    
    double mLastPresentationTime;
    double mTotalPresentationTime;
    UInt32 mEncodeStartTimestamp;
    
    AudioMuxer mAudioMuxer;
    AudioFrame mAudioEncodedFrame;
    
    // 状态锁
    KMutex mRuningMutex;
};
}

#endif /* AudioHardEncoder_h */
