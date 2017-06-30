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

#import <AVFoundation/AVFoundation.h>

namespace coollive {
class RtmpPlayer;
class AudioHardDecoder : public AudioDecoder {
public:
    AudioHardDecoder();
    virtual ~AudioHardDecoder();
    
public:
    bool Create(AudioDecoderCallback* callback);
    void Destroy();
    void Reset();
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
    void ReleaseAudioFrame(void* frame);
    
private:
    static void inPropertyListenerProc(
                                       void *inClientData,
                                       AudioFileStreamID inAudioFileStream,
                                       AudioFileStreamPropertyID inPropertyID,
                                       UInt32 *ioFlags);
    
    static void inPacketsProc(
                              void *inClientData,
                              UInt32 inNumberBytes,
                              UInt32 inNumberPackets,
                              const void *inInputData,
                              AudioStreamPacketDescription *inPacketDescriptions
                              );
    

private:
    AudioDecoderCallback* mpCallback;
    
    AudioFileStreamID audioFileStream;
};
}

#endif /* AudioHardDecoder_h */
