/*
 * IEncoder.h
 *
 *  Created on: 2017年5月8日
 *      Author: max
 */

#ifndef RTMPDUMP_IENCODER_H_
#define RTMPDUMP_IENCODER_H_

#include "ICodec.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

namespace coollive {
class VideoEncoder;
class VideoEncoderCallback {
  public:
    virtual ~VideoEncoderCallback(){};
    virtual void OnEncodeVideoFrame(VideoEncoder *encoder, char *data, int size, u_int32_t ts) = 0;
};

class VideoEncoder {
  public:
    virtual ~VideoEncoder(){};
    virtual bool Create(int width, int height, int bitRate, int keyFrameInterval, int fps, VIDEO_FORMATE_TYPE type) = 0;
    virtual void SetCallback(VideoEncoderCallback *callback) = 0;
    virtual bool Reset() = 0;
    virtual void Pause() = 0;
    virtual void EncodeVideoFrame(void *data, int size, void *frame) = 0;
};

class AudioEncoder;
class AudioEncoderCallback {
  public:
    virtual ~AudioEncoderCallback(){};
    virtual void OnEncodeAudioFrame(AudioEncoder *encoder,
                                    AudioFrameFormat format,
                                    AudioFrameSoundRate sound_rate,
                                    AudioFrameSoundSize sound_size,
                                    AudioFrameSoundType sound_type,
                                    char *frame,
                                    int size,
                                    u_int32_t ts) = 0;
};

class AudioEncoder {
  public:
    virtual ~AudioEncoder(){};
    virtual bool Create(int sampleRate, int channelsPerFrame, int bitPerSample) = 0;
    virtual void SetCallback(AudioEncoderCallback *callback) = 0;
    virtual bool Reset() = 0;
    virtual void Pause() = 0;
    virtual void EncodeAudioFrame(void *data, int size, void *frame) = 0;
};
}
#endif /* RTMPDUMP_IENCODER_H_ */
