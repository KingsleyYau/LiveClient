//
//  AudioHardDecoder.h
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  音频硬解码器

#ifndef AudioHardDecoder_h
#define AudioHardDecoder_h

#include <rtmpdump/IDecoder.h>

class RtmpPlayer;
class AudioHardDecoder : public AudioDecoder {
public:
    AudioHardDecoder();
    virtual ~AudioHardDecoder();
    
public:
    bool Create(RtmpPlayer* player);
    void CreateAudioDecoder(
                            AudioFrameFormat format,
                            AudioFrameSoundRate sound_rate,
                            AudioFrameSoundSize sound_size,
                            AudioFrameSoundType sound_type
                            );
    
    void DecodeAudioFrame(
                          AudioFrameFormat format,
                          AudioFrameSoundRate sound_rate,
                          AudioFrameSoundSize sound_size,
                          AudioFrameSoundType sound_type,
                          const char* data,
                          int size,
                          u_int32_t timestamp
                          );
    
private:
    RtmpPlayer* mpPlayer;
};


#endif /* AudioHardDecoder_h */
