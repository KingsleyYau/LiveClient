//
//  AudioRendererImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioRendererImp.h"

#include <common/KLog.h>

// 音频播放Buffer的大小(Bytes)
#define AUDIO_BUFFER_SIZE 10240
#define AUDIO_BUFFER_COUNT 250

AudioRendererImp::AudioRendererImp() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::AudioRendererImp( "
                 "this : %p "
                 ")",
                 this
                 );
    mAudioQueue = NULL;
    mIsMute = false;
    mPlaybackRate = 1.0f;
    mPlaybackRateChange = true;
//    Create();
}

AudioRendererImp::~AudioRendererImp() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::~AudioRendererImp( "
                 "this : %p "
                 ")",
                 this
                 );
    
    mAudioBufferList.lock();
    while( !mAudioBufferList.empty() ) {
        AudioQueueBufferRef audioBuffer = mAudioBufferList.front();
        if( audioBuffer != NULL ) {
            mAudioBufferList.pop_front();
            // 释放内存
            AudioQueueFreeBuffer(mAudioQueue, audioBuffer);
            
        } else {
            break;
        }
    }
    mAudioBufferList.unlock();
    
    if ( mAudioQueue ) {
        AudioQueueDispose(mAudioQueue, YES);
    }
}

void AudioRendererImp::RenderAudioFrame(void* frame) {
    // 播放音频
    AudioFrame* audioFrame = (AudioFrame *)frame;
    OSStatus status = noErr;
    
    // 创建播放器
    if( Create(frame) ) {
        // 申请音频包内存
        AudioQueueBufferRef audioBuffer = NULL;
        mAudioBufferList.lock();
        if( mAudioBufferList.empty() ) {
            status = AudioQueueAllocateBuffer(mAudioQueue, AUDIO_BUFFER_SIZE, &audioBuffer);
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [New More AudioBuffer], audioBuffer : %p, timestamp : %u )", audioBuffer, audioFrame->mTimestamp);
            
        } else {
            audioBuffer = mAudioBufferList.front();
            mAudioBufferList.pop_front();
        }
        mAudioBufferList.unlock();
    
        if( status == noErr && audioBuffer != NULL ) {
            // 复制内容
            audioBuffer->mAudioDataByteSize = audioFrame->mBufferLen;
            if( !mIsMute ) {
                memcpy(audioBuffer->mAudioData, (const char *)audioFrame->GetBuffer(), audioFrame->mBufferLen);
            } else {
                memset(audioBuffer->mAudioData, 0, audioFrame->mBufferLen);
            }
            
            // 放入音频包
            // https://developer.apple.com/library/content/qa/qa1718/_index.html#//apple_ref/doc/uid/DTS40010356
//            status = AudioQueueEnqueueBuffer(mAudioQueue, audioBuffer, 0, NULL);
            AudioTimeStamp outActualStartTime;
            status = AudioQueueEnqueueBufferWithParameters(mAudioQueue, audioBuffer, 0, NULL, 0, 0, 0, NULL, NULL, &outActualStartTime);
            if( status == noErr ) {
                FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioRendererImp::RenderAudioFrame( this : %p, audioBuffer : %p, size : %d, mSampleTime : %f )", this,
                             audioBuffer, audioFrame->mBufferLen, outActualStartTime.mSampleTime);
            } else {
                FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [AudioQueueEnqueueBuffer Fail], this : %p, status : %d )", this, (int)status);
            }
            
        } else {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [AudioQueueAllocateBuffer Fail], this : %p, status : %d )", this, (int)status);
        }
    }
}

bool AudioRendererImp::Start() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::Start( "
                 "this : %p "
                 ")",
                 this
                 );
    
    BOOL bFlag = YES;
    if( mAudioQueue ) {
        // 开始播放
        OSStatus status = noErr;
        status = AudioQueueStart(mAudioQueue, NULL);
        if( status == noErr ) {
            bFlag = true;
        }
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioRendererImp::Start( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag?"Success":"Fail"
                 );
    
    return bFlag;
}

void AudioRendererImp::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::Stop( "
                 "this : %p "
                 ")",
                 this
                 );
    
    if( mAudioQueue ) {
        AudioQueueStop(mAudioQueue, YES);
        AudioQueueReset(mAudioQueue);
        AudioQueueFlush(mAudioQueue);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioRendererImp::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this
                 );
}

void AudioRendererImp::Reset() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::Reset( "
                 "this : %p "
                 ")",
                 this
                 );
    
    if( mAudioQueue ) {
        AudioQueueReset(mAudioQueue);
        AudioQueueFlush(mAudioQueue);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::Reset( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this
                 );
}

bool AudioRendererImp::GetMute() {
    return mIsMute;
}

void AudioRendererImp::SetMute(bool isMute) {
    mIsMute = isMute;
}

void AudioRendererImp::SetPlaybackRate(float playbackRate) {
    mPlaybackRate = playbackRate;
    mPlaybackRateChange = true;
}

bool AudioRendererImp::Create(void *frame) {
    AudioFrame* audioFrame = (AudioFrame *)frame;
    
    bool bFlag = true;
    
    int channels = 1;
    if ( audioFrame ) {
        channels = (audioFrame->mSoundType==AFST_STEREO)?2:1;
    }
    
    AudioStreamBasicDescription asbd;
    FillOutASBDForLPCM(asbd,
                       44100,   // Sample Rate
                       channels,       // Channels Per Frame
                       16,      // Valid Bits Per Channel
                       16,      // Total Bits Per Channel
                       false,
                       false
                       );
    
    if ( (mAsbd.mChannelsPerFrame != asbd.mChannelsPerFrame) || mPlaybackRateChange ) {
        if( mAudioQueue ) {
            AudioQueueReset(mAudioQueue);
            mAudioBufferList.lock();
            while( !mAudioBufferList.empty() ) {
                AudioQueueReset(mAudioQueue);
                AudioQueueFlush(mAudioQueue);
                AudioQueueBufferRef audioBuffer = mAudioBufferList.front();
                if( audioBuffer != NULL ) {
                    mAudioBufferList.pop_front();
                    // 释放内存
                    AudioQueueFreeBuffer(mAudioQueue, audioBuffer);
                    
                } else {
                    break;
                }
            }
            mAudioBufferList.unlock();
            AudioQueueDispose(mAudioQueue, YES);
            mAudioQueue = NULL;
        }
        mAsbd = asbd;
    }
    
    // Create the audio queue
    if( !mAudioQueue ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "AudioRendererImp::Create( "
                     "this : %p "
                     ")",
                     this
                     );
        
        bFlag = false;
        
        OSStatus status = noErr;
        status = AudioQueueNewOutput(&asbd, AudioQueueOutputCallback, this, NULL, NULL, 0, &mAudioQueue);
        if( status == noErr ) {
            // 开启音频加速
            UInt32 enabled = 1;
            AudioQueueSetProperty(mAudioQueue, kAudioQueueProperty_EnableTimePitch, &enabled, sizeof(enabled));
            UInt32 algorithm = kAudioQueueTimePitchAlgorithm_Spectral;
            AudioQueueSetProperty(mAudioQueue, kAudioQueueProperty_TimePitchAlgorithm, &algorithm, sizeof(algorithm));
            
            // 设置音量
            Float32 gain = 1.0;
            AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_Volume, gain);
            AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_PlayRate, mPlaybackRate);
//            // 申请音频包内存
//            AudioQueueBufferRef audioBuffer;
//            for(int i = 0; i < AUDIO_BUFFER_COUNT; i++) {
//                status = AudioQueueAllocateBuffer(mAudioQueue, AUDIO_BUFFER_SIZE, &audioBuffer);
//                if( status == noErr ) {
//                    mAudioBufferList.lock();
//                    mAudioBufferList.push_back(audioBuffer);
//                    mAudioBufferList.unlock();
//                }
//            }
            AudioQueueStart(mAudioQueue, NULL);
        }
    }
    
    return bFlag;
}

void AudioRendererImp::AudioQueueOutputCallback(
                                                void * __nullable       inUserData,
                                                AudioQueueRef           inAQ,
                                                AudioQueueBufferRef     inBuffer
                                                ) {
    AudioRendererImp* renderer = (AudioRendererImp *)inUserData;
    
    if( renderer ) {
        FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioRendererImp::AudioQueueOutputCallback( this : %p, audioBuffer : %p, size : %d )", renderer, inBuffer, renderer->mAudioBufferList.size());
        
        // 归还缓存
        renderer->mAudioBufferList.lock();
        renderer->mAudioBufferList.push_back(inBuffer);
        renderer->mAudioBufferList.unlock();
        
        // 释放内存
//        AudioQueueFreeBuffer(inAQ, inBuffer);
    }

}
