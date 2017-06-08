//
//  IDecoder.h
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef IDecoder_h
#define IDecoder_h

#include "ICodec.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

class RtmpPlayer;
class VideoDecoder {
public:
    VideoDecoder() {};
    virtual ~VideoDecoder(){};
    virtual bool Create(RtmpPlayer* player) = 0;
    virtual void Destroy() = 0;
    virtual void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) = 0;
    virtual void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) = 0;
};

class AudioDecoder {
public:
    virtual ~AudioDecoder(){};
    virtual bool Create(RtmpPlayer* player) = 0;
    virtual void CreateAudioDecoder(
    		AudioFrameFormat format,
			AudioFrameSoundRate sound_rate,
			AudioFrameSoundSize sound_size,
			AudioFrameSoundType sound_type
			) = 0;
    
    virtual void DecodeAudioFrame(
    		AudioFrameFormat format,
			AudioFrameSoundRate sound_rate,
			AudioFrameSoundSize sound_size,
			AudioFrameSoundType sound_type,
			const char* data,
			int size,
			u_int32_t timestamp
			) = 0;
};

#endif /* IDecoder_h */
