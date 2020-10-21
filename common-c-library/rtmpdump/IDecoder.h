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

#include <string>
using namespace std;

namespace coollive {

class VideoDecoder;
class VideoDecoderCallback {
  public:
    virtual ~VideoDecoderCallback(){};
    virtual void OnDecodeVideoChangeSize(VideoDecoder *decoder, unsigned int displayWidth, unsigned int displayHeight) = 0;
    virtual void OnDecodeVideoFrame(VideoDecoder *decoder, void *frame, u_int32_t ts) = 0;
    virtual void OnDecodeVideoError(VideoDecoder *decoder) = 0;
};

class VideoDecoder {
  public:
    VideoDecoder(){};
    virtual ~VideoDecoder(){};
    virtual bool Create(VideoDecoderCallback *callback) = 0;
    virtual bool Reset() = 0;
    virtual void Pause() = 0;
    virtual void ResetStream() = 0;
    virtual void DecodeVideoKeyFrame(const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, u_int32_t ts,const char *vps = NULL, int vps_size = 0) = 0;
    virtual void DecodeVideoFrame(const char *data, int size, u_int32_t dts, u_int32_t pts, VideoFrameType video_type) = 0;
    virtual void ReleaseVideoFrame(void *frame) = 0;
    virtual void StartDropFrame() = 0;
    virtual void ClearVideoFrame() = 0;
};

class AudioDecoder;
class AudioDecoderCallback {
  public:
    virtual ~AudioDecoderCallback(){};
    virtual void OnDecodeAudioFrame(AudioDecoder *decoder, void *frame, u_int32_t ts) = 0;
    virtual void OnDecodeAudioError(AudioDecoder *decoder) = 0;
};

class AudioDecoder {
  public:
    virtual ~AudioDecoder(){};
    virtual bool Create(AudioDecoderCallback *callback) = 0;
    virtual bool Reset() = 0;
    virtual void Pause() = 0;
    virtual void DecodeAudioFormat(
        AudioFrameFormat format,
        AudioFrameSoundRate sound_rate,
        AudioFrameSoundSize sound_size,
        AudioFrameSoundType sound_type) = 0;
    virtual void DecodeAudioFrame(
        AudioFrameFormat format,
        AudioFrameSoundRate sound_rate,
        AudioFrameSoundSize sound_size,
        AudioFrameSoundType sound_type,
        const char *data,
        int size,
        u_int32_t ts) = 0;
    virtual void ReleaseAudioFrame(void *frame) = 0;
    virtual void ClearAudioFrame() = 0;
};
}
#endif /* IDecoder_h */
