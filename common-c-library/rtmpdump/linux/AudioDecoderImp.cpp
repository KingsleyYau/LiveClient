/*
 * AudioDecoderImp.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "AudioDecoderImp.h"

#include <common/KLog.h>

#include <rtmpdump/RtmpPlayer.h>

namespace coollive {
AudioDecoderImp::AudioDecoderImp() {
	// TODO Auto-generated constructor stub
	FileLog("rtmpdump", "AudioDecoderImp::AudioDecoderImp( this : %p )", this);
    mpCallback = NULL;
}

AudioDecoderImp::~AudioDecoderImp() {
	// TODO Auto-generated destructor stub
	FileLog("rtmpdump", "AudioDecoderImp::~AudioDecoderImp( this : %p )", this);

    AudioFrame* frame = NULL;

	// 释放空闲Buffer
	mFreeBufferList.lock();
	while( !mFreeBufferList.empty() ) {
		frame = (AudioFrame* )mFreeBufferList.front();
		mFreeBufferList.pop_front();
		if( frame != NULL ) {
			delete frame;
		} else {
			break;
		}
	}
	mFreeBufferList.unlock();
}

bool AudioDecoderImp::Create(AudioDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderImp::Create( this : %p )", this);

    mpCallback = callback;
    
    return true;
}

void AudioDecoderImp::Destroy() {
	FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderImp::Destroy( this : %p )", this);
}
    
    
void AudioDecoderImp::ReleaseAudioFrame(void* frame) {
    AudioFrame* audioFrame = (AudioFrame *)frame;
    ReleaseBuffer(audioFrame);
}

void AudioDecoderImp::ReleaseBuffer(AudioFrame* audioFrame) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(audioFrame);
	mFreeBufferList.unlock();
}

void AudioDecoderImp::DecodeAudioFormat(
		AudioFrameFormat format,
		AudioFrameSoundRate sound_rate,
		AudioFrameSoundSize sound_size,
		AudioFrameSoundType sound_type
		) {
	FileLog("rtmpdump", "AudioDecoderImp::DecodeAudioFormat( this : %p )", this);
}

void AudioDecoderImp::DecodeAudioFrame(
		AudioFrameFormat format,
		AudioFrameSoundRate sound_rate,
		AudioFrameSoundSize sound_size,
		AudioFrameSoundType sound_type,
		const char* data,
		int size,
		u_int32_t timestamp
		) {
	mFreeBufferList.lock();
	AudioFrame* audioFrame = NULL;
	if( !mFreeBufferList.empty() ) {
		audioFrame = (AudioFrame *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		audioFrame = new AudioFrame();
	}
	mFreeBufferList.unlock();

    // 更新数据格式
	audioFrame->ResetFrame();
    audioFrame->mTimestamp = timestamp;
    audioFrame->mFormat = format;
    audioFrame->mSoundRate = sound_rate;
    audioFrame->mSoundSize = sound_size;
    audioFrame->mSoundType = sound_type;
    audioFrame->SetBuffer((const unsigned char*)data, size);
    
    if( mpCallback && audioFrame ) {
        mpCallback->OnDecodeAudioFrame(this, audioFrame, audioFrame->mTimestamp);
    } else {
        // 归还没使用Buffer
        if( audioFrame ) {
            ReleaseBuffer(audioFrame);
            audioFrame = NULL;
        }
    }
}

}
