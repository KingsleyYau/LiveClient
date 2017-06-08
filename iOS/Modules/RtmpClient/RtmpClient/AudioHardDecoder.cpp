//
//  AudioHardDecoder.cpp
//  RtmpClient
//
//  Created by  Samson on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  音频硬解码器

#include "AudioHardDecoder.h"
#include <rtmpdump/RtmpPlayer.h>
#include <common/KLog.h>
#import <AudioToolbox/AudioToolbox.h>

AudioHardDecoder::AudioHardDecoder()
{
    mpPlayer = NULL;
}

AudioHardDecoder::~AudioHardDecoder()
{

}

bool AudioHardDecoder::Create(RtmpPlayer* player)
{
    bool result = false;
    if (NULL != player) {
        mpPlayer = player;
    }
    return result;
}

void AudioHardDecoder::CreateAudioDecoder(
                        AudioFrameFormat format,
                        AudioFrameSoundRate sound_rate,
                        AudioFrameSoundSize sound_size,
                        AudioFrameSoundType sound_type
                        )
{

}

void AudioHardDecoder::DecodeAudioFrame(
                      AudioFrameFormat format,
                      AudioFrameSoundRate sound_rate,
                      AudioFrameSoundSize sound_size,
                      AudioFrameSoundType sound_type,
                      const char* data,
                      int size,
                      u_int32_t timestamp
                      )
{
    if (NULL != mpPlayer) {
        CFDataRef dataRef = CFDataCreate(NULL, (const u_int8_t *)data, size);
        mpPlayer->PushAudioFrame((void*)dataRef, timestamp);
    }
}
