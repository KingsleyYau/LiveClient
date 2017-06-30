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
class VideoEncoder {
public:
    virtual ~VideoEncoder(){};
    virtual bool Create(int width, int height, int frameInterval, int bitRate, int keyFrameInterval) = 0;
    virtual void Destroy() = 0;
    virtual void EncodeVideoFrame(const char* data, int size, u_int32_t timestamp) = 0;
    virtual void ReleaseVideoFrame(void* frame) = 0;
};

class AudioEncoder {
public:
	virtual ~AudioEncoder(){};
    virtual bool Create(int sampleRate, int channelsPerFrame, int bitPerSample) = 0;
    virtual void Destroy() = 0;
    virtual void EncodeAudioFrame(const char* data, int size, u_int32_t timestamp) = 0;
    virtual void ReleaseAudioFrame(void* frame) = 0;
};
}
#endif /* RTMPDUMP_IENCODER_H_ */
