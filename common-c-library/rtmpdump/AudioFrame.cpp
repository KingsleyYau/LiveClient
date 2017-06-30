//
//  AudioFrame.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include <common/KLog.h>

#include "AudioFrame.h"

namespace coollive {
AudioFrame::AudioFrame() {
    ResetFrame();
}

AudioFrame::~AudioFrame() {
}

void AudioFrame::ResetFrame() {
	EncodeDecodeBuffer::ResetFrame();

    mFormat = AFF_UNKNOWN;
    mSoundRate = AFSR_UNKNOWN;
    mSoundSize = AFSS_UNKNOWN;
    mSoundType = AFST_UNKNOWN;
}
}
