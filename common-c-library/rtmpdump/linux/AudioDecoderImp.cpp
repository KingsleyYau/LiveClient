/*
 * AudioDecoderImp.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "AudioDecoderImp.h"

#include <common/KLog.h>

#include <rtmpdump/RtmpPlayer.h>
#include <rtmpdump/audio/AudioFrame.h>

namespace coollive {
AudioDecoderImp::AudioDecoderImp()
:mRuningMutex(KMutex::MutexType_Recursive)
{
	// TODO Auto-generated constructor stub
	FileLog("rtmpdump", "AudioDecoderImp::AudioDecoderImp( this : %p )", this);

    mpCallback = NULL;
    mbRunning = false;
}

AudioDecoderImp::~AudioDecoderImp() {
	// TODO Auto-generated destructor stub
	FileLog("rtmpdump", "AudioDecoderImp::~AudioDecoderImp( this : %p )", this);

	Stop();
}

bool AudioDecoderImp::Create(AudioDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioDecoderImp::Create( this : %p )", this);

    mpCallback = callback;
    
    return true;
}

bool AudioDecoderImp::Reset() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioDecoderImp::Pause( this : %p )", this);

    bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderImp::Reset( "
                 "[%s], "
                 "this : %p "
                 ")",
                 bFlag?"Success":"Fail",
                 this
                 );

    return bFlag;
}

void AudioDecoderImp::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioDecoderImp::Pause( this : %p )", this);

    Stop();
}

bool AudioDecoderImp::Start() {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderImp::Start( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }

	AudioFrame* frame = NULL;
	mFreeBufferList.lock();
	for(int i = 0; i < DEFAULT_AUDIO_BUFFER_COUNT; i++) {
		frame = new AudioFrame();
		frame->ResetFrame();
		mFreeBufferList.push_back(frame);
	}
	mFreeBufferList.unlock();

    mbRunning = true;

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderImp::Start( "
                 "[%s], "
                 "this : %p "
                 ")",
                 bFlag?"Success":"Fail",
                 this
                 );

    return bFlag;
}

void AudioDecoderImp::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderImp::Stop( "
                 "this : %p "
                 ")",
                 this
                 );
    
    mRuningMutex.lock();
    if( mbRunning ) {
        mbRunning = false;

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
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderImp::Stop( "
                 "[Success], "
                 "this : %p "
                 ")",
                 this
                 );
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
    audioFrame->mSoundFormat = format;
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
