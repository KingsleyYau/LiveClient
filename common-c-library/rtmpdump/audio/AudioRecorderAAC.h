//
//  AudioRecorderAAC.hpp
//  RtmpClient
//
//  Created by Max on 2017/8/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AudioRecorderAAC_h
#define AudioRecorderAAC_h

#include <rtmpdump/audio/AudioFrame.h>
#include <rtmpdump/audio/AudioMuxer.h>

#include <stdio.h>

#include <string>
using namespace std;

namespace coollive {
class AudioRecorderAAC {
public:
    AudioRecorderAAC();
    ~AudioRecorderAAC();
    
    bool Start(const string& filePath);
    void Stop();
    
    void ChangeAudioFormat(
                           AudioFrameFormat format,
                           AudioFrameSoundRate sound_rate,
                           AudioFrameSoundSize sound_size,
                           AudioFrameSoundType sound_type
                           );
    bool RecordAudioFrame(const char* data, int size);
    
private:
    string mFilePath;
    FILE* mpFile;
    
    AudioFrameFormat mFormat;
    AudioFrameSoundRate mSoundRate;
    AudioFrameSoundSize mSoundSize;
    AudioFrameSoundType mSoundType;
    
    AudioFrame mAudioFrame;
    AudioMuxer mAudioMuxer;
};
}

#endif /* AudioRecorderAAC_h */
