//
//  AudioFrame.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include "AudioFrame.h"

#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
}

#define DEFAULT_AUDIO_FRAME_SIZE 2048

namespace coollive {
AudioFrame::AudioFrame() {
    mpAVFrame = av_frame_alloc();

    ResetFrame();
}

AudioFrame::~AudioFrame() {
    if (mpAVFrame) {
        av_frame_free(&mpAVFrame);
        mpAVFrame = NULL;
    }
}

AudioFrame::AudioFrame(const AudioFrame &item)
    : EncodeDecodeBuffer(item) {
    mpAVFrame = av_frame_alloc();

    ResetFrame();

    mSoundFormat = item.mSoundFormat;
    mSoundRate = item.mSoundRate;
    mSoundSize = item.mSoundSize;
    mSoundType = item.mSoundType;
}

AudioFrame &AudioFrame::operator=(const AudioFrame &item) {
    if (this == &item) {
        return *this;
    }

    EncodeDecodeBuffer::operator=(item);

    mSoundFormat = item.mSoundFormat;
    mSoundRate = item.mSoundRate;
    mSoundSize = item.mSoundSize;
    mSoundType = item.mSoundType;

    return *this;
}

void AudioFrame::ResetFrame() {
    EncodeDecodeBuffer::ResetBuffer();

    mSoundFormat = AFF_UNKNOWN;
    mSoundRate = AFSR_UNKNOWN;
    mSoundSize = AFSS_UNKNOWN;
    mSoundType = AFST_UNKNOWN;
}

void AudioFrame::InitFrame(AudioFrameFormat format, AudioFrameSoundRate rate, AudioFrameSoundSize size, AudioFrameSoundType channel) {
    mSoundFormat = format;
    mSoundRate = rate;
    mSoundSize = size;
    mSoundType = channel;

    RenewBufferSize(DEFAULT_AUDIO_FRAME_SIZE);
}

}
