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

namespace coollive {
AudioHardDecoder::AudioHardDecoder()
{
    mpCallback = NULL;
    audioFileStream = NULL;
}

AudioHardDecoder::~AudioHardDecoder()
{
    Pause();
}

bool AudioHardDecoder::Create(AudioDecoderCallback* callback)
{
    bool result = false;
    
    Pause();
    
    if ( NULL != callback ) {
        mpCallback = callback;
        
        if( !audioFileStream ) {
            OSStatus status = AudioFileStreamOpen(this, inPropertyListenerProc, inPacketsProc, kAudioFileAAC_ADTSType, &audioFileStream);
            result = (status == noErr);
            if( status != noErr ) {

            }
        }
    }
    
    return result;
}

void AudioHardDecoder::Pause() {
    if( audioFileStream ) {
        AudioFileStreamClose(audioFileStream);
        audioFileStream = NULL;
    }

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
    if (NULL != mpCallback) {
        CFDataRef dataRef = CFDataCreate(NULL, (const u_int8_t *)data, size);
        mpCallback->OnDecodeAudioFrame(this, (void *)dataRef, timestamp);
    }
}

void AudioHardDecoder::inPropertyListenerProc(
                                              void *						inClientData,
                                              AudioFileStreamID				inAudioFileStream,
                                              AudioFileStreamPropertyID		inPropertyID,
                                              UInt32 *						ioFlags
                                              ) {
    
//    AudioHardDecoder* decoder = (AudioHardDecoder *)inClientData;
//    OSStatus status = noErr;
//    UInt32 size = 0;
//    
//    switch (inPropertyID) {
//        case kAudioFileStreamProperty_ReadyToProducePackets :
//        {
//            // the file stream parser is now ready to produce audio packets.
//            // get the stream format.
//            AudioStreamBasicDescription asbd;
//            size = sizeof(asbd);
//            status = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &size, &asbd);
//            
//            // create the audio queue
//            if( status == noErr ) {
//
//            }
//            
//        }break;
//            
//    }
    
}

void AudioHardDecoder::inPacketsProc(
                                     void *							inClientData,
                                     UInt32							inNumberBytes,
                                     UInt32							inNumberPackets,
                                     const void *                     inInputData,
                                     AudioStreamPacketDescription *   inPacketDescriptions
                                     ) {
//    AudioHardDecoder* decoder = (AudioHardDecoder *)inClientData;
//    OSStatus status = noErr;
    
//    for (int i = 0; i < inNumberPackets; ++i) {
//        SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
//        UInt32 packetSize   = inPacketDescriptions[i].mDataByteSize;
//        
//        // 放入音频包
////        AudioStreamPacketDescription desc = inPacketDescriptions[i];
////        desc.mStartOffset = 0;
//        
//    }
}
}
