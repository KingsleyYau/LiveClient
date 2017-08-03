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

#include <rtmpdump/IEncoder.h>

#include <CoreFoundation/CoreFoundation.h>
#include <AVFoundation/AVFoundation.h>

namespace coollive {
class AudioHardEncoder : public AudioEncoder {
public:
    AudioHardEncoder();
    virtual ~AudioHardEncoder();
    
public:
    bool Create(AudioEncoderCallback* callback, int sampleRate, int channelsPerFrame, int bitPerSample);
    void Pause();
    void EncodeAudioFrame(void* frame);
    
private:
    static OSStatus inInputDataProc(AudioConverterRef inAudioConverter,
                                    UInt32 *ioNumberDataPackets,
                                    AudioBufferList *ioData,
                                    AudioStreamPacketDescription **outDataPacketDescription,
                                    void *inUserData
                                    );
        
private:
    bool Reset(CMSampleBufferRef sampleBuffer);
    
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
};
}

#endif /* AudioHardEncoder_h */
