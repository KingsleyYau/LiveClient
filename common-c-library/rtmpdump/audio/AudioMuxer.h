//
//  AudioMuxer.h
//  RtmpClient
//
//  Created by Max on 2017/8/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AudioMuxer_h
#define AudioMuxer_h

#include <rtmpdump/ICodec.h>

#include <stdio.h>

namespace coollive {
class AudioMuxer {
public:
    AudioMuxer();
    ~AudioMuxer();
    
    /**
     增加ADTS头部
     (Audio Data Transport Stream 音频数据传输流)

     @param frameSize <#frameSize description#>
     @param format <#format description#>
     @param sampleRate <#sampleRate description#>
     @param bitPerChannel <#bitPerChannel description#>
     @param channels <#channels description#>
     @param header <#header description#>
     @param headerCapacity <#headerCapacity description#>
     @param headerSize <#headerSize description#>
     @return <#return value description#>
     */
    bool GetADTS(
                 int frameSize,
                 AudioFrameFormat format,
                 AudioFrameSoundRate sampleRate,
                 AudioFrameSoundSize bitPerChannel,
                 AudioFrameSoundType channels,
                 char *header,
                 int headerCapacity,
                 int &headerSize
                 );
};
}

#endif /* AudioMuxer_h */
