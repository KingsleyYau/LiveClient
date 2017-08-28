//
//  AudioMuxer.cpp
//  RtmpClient
//
//  Created by Max on 2017/8/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioMuxer.h"

#define ADTS_HEADER_SIZE 7

namespace coollive {
AudioMuxer::AudioMuxer() {
    
}

AudioMuxer::~AudioMuxer() {
    
}
    
bool AudioMuxer::GetADTS(
                         int frameSize,
                         AudioFrameFormat format,
                         AudioFrameSoundRate sampleRate,
                         AudioFrameSoundSize bitPerChannel,
                         AudioFrameSoundType channels,
                         char *header,
                         int headerCapacity,
                         int &headerSize
                         ) {
    bool bFlag = false;
    
    if( header != NULL && headerCapacity >= ADTS_HEADER_SIZE ) {
        if(
           format == AFF_AAC &&
           sampleRate == AFSR_KHZ_44 &&
           bitPerChannel == AFSS_BIT_16
//           && channels == AFST_MONO // 由于ffmpeg的rtmp固定发送AFST_STEREO, 强制转为AFST_MONO
           ) {
            int profile = 2;  // AAC LC
            
            int freqIdx = 4;  // 44.1KHz
            
            int chanCfg = 1;  // MPEG-4 Audio Channel Configuration. 1 Channel front-center
            int fullSize = ADTS_HEADER_SIZE + frameSize;
            
            // Fill in ADTS data
            header[0] = (char)0xFF; // 11111111     = syncword
            header[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
            header[2] = (char)(((profile - 1) << 6 ) + (freqIdx << 2) + (chanCfg >> 2));
            header[3] = (char)(((chanCfg & 3) << 6) + (fullSize >> 11));
            header[4] = (char)((fullSize & 0x7FF) >> 3);
            header[5] = (char)(((fullSize & 7) << 5) + 0x1F);
            header[6] = (char)0xFC;
            
            headerSize = ADTS_HEADER_SIZE;
            
            bFlag = true;
        }
    }
    
    return bFlag;
}
}
