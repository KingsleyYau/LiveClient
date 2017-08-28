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
const size_t kAQBufSize = 65536;

AudioRendererImp::AudioRendererImp() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioRendererImp::AudioRendererImp( "
                 "this : %p "
                 ")",
                 this
                 );
    mAudioQueue = NULL;
    
    Create();
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
}

void AudioRendererImp::RenderAudioFrame(void* frame) {
    // 播放音频
    AudioFrame* audioFrame = (AudioFrame *)frame;
    OSStatus status = noErr;
    
    // 创建播放器
//    if( Create(audioFrame) ) {
        // 申请音频包内存
        AudioQueueBufferRef audioBuffer = NULL;
        mAudioBufferList.lock();
        if( mAudioBufferList.empty() ) {
            status = AudioQueueAllocateBuffer(mAudioQueue, kAQBufSize, &audioBuffer);
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [No More Cache AudioBuffer], this : %p )", this);
            
        } else {
            audioBuffer = mAudioBufferList.front();
            mAudioBufferList.pop_front();
        }
        mAudioBufferList.unlock();
    
        if( status == noErr && audioBuffer != NULL ) {
            // 复制内容
            audioBuffer->mAudioDataByteSize = audioFrame->mBufferLen;
            memcpy(audioBuffer->mAudioData, (const char *)audioFrame->GetBuffer(), audioFrame->mBufferLen);
            
            // 放入音频包
            // https://developer.apple.com/library/content/qa/qa1718/_index.html#//apple_ref/doc/uid/DTS40010356
//            status = AudioQueueEnqueueBuffer(mAudioQueue, audioBuffer, 0, NULL);
            AudioTimeStamp outActualStartTime;
            status = AudioQueueEnqueueBufferWithParameters(mAudioQueue, audioBuffer, 0, NULL, 0, 0, 0, NULL, NULL, &outActualStartTime);
            if( status == noErr ) {
                FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioRendererImp::RenderAudioFrame( this : %p, audioBuffer : %p, mSampleTime : %f )", this,
                             audioBuffer, outActualStartTime.mSampleTime);
            } else {
                FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [AudioQueueEnqueueBuffer Fail], this : %p, status : %d )", this, (int)status);
            }
            
        } else {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioRendererImp::RenderAudioFrame( [AudioQueueAllocateBuffer Fail], this : %p, status : %d )", this, (int)status);
        }
//    }
}

void AudioRendererImp::Reset() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioRendererImp::Reset( "
                 "this : %p "
                 ")",
                 this
                 );
    
    if( mAudioQueue ) {
        AudioQueueReset(mAudioQueue);
        AudioQueueFlush(mAudioQueue);
    }
}

bool AudioRendererImp::Create() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioRendererImp::Create( "
                 "this : %p "
                 ")",
                 this
                 );
    
    bool bFlag = true;
    
    AudioStreamBasicDescription asbd;
    FillOutASBDForLPCM(asbd,
                       44100,   // Sample Rate
                       1,       // Channels Per Frame
                       16,      // Valid Bits Per Channel
                       16,      // Total Bits Per Channel
                       false,
                       false
                       );
    
//    asbd.mSampleRate = 44100;
//    asbd.mFormatID = kAudioFormatLinearPCM;
//    asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
//    asbd.mFramesPerPacket = 1;
//    asbd.mBitsPerChannel = 16;
//    asbd.mChannelsPerFrame = 1;
//    asbd.mBytesPerFrame = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
//    asbd.mBytesPerPacket = asbd.mBytesPerFrame * asbd.mFramesPerPacket;
//    asbd.mReserved = 0;
    
    // Create the audio queue
    if( !mAudioQueue ) {
        bFlag = false;
        
        OSStatus status = noErr;
        status = AudioQueueNewOutput(&asbd, AudioQueueOutputCallback, this, NULL, NULL, 0, &mAudioQueue);
        if( status == noErr ) {
            // 设置音量
            Float32 gain = 1.0;
            AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_Volume, gain);
            
            // 申请音频包内存
            AudioQueueBufferRef audioBuffer;
            for(int i = 0; i < 50; i++) {
                status = AudioQueueAllocateBuffer(mAudioQueue, kAQBufSize, &audioBuffer);
                if( status == noErr ) {
                    mAudioBufferList.lock();
                    mAudioBufferList.push_back(audioBuffer);
                    mAudioBufferList.unlock();
                }
            }
            
            // 开始播放
            status = AudioQueueStart(mAudioQueue, NULL);
            if( status == noErr ) {
                bFlag = true;
            }
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
        FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioRendererImp::AudioQueueOutputCallback( this : %p, audioBuffer : %p )", renderer, inBuffer);
        
        // 归还缓存
        renderer->mAudioBufferList.lock();
        renderer->mAudioBufferList.push_back(inBuffer);
        renderer->mAudioBufferList.unlock();
        
        // 释放内存
//        AudioQueueFreeBuffer(inAQ, inBuffer);
    }

}
