//
//  RtmpPublisher.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPublisher.h"

// 发布休眠
#define PUBLISH_SLEEP_TIME 1

namespace coollive {
class PublishRunnable : public KRunnable {
public:
    PublishRunnable(RtmpPublisher *container) {
        mContainer = container;
    }
    virtual ~PublishRunnable() {
        mContainer = NULL;
    }
protected:
    void onRun() {
        mContainer->PublishHandle();
    }
    
private:
    RtmpPublisher *mContainer;
};
    
RtmpPublisher::RtmpPublisher()
    :mClientMutex(KMutex::MutexType_Recursive)
    {
    FileLog("rtmpdump", "RtmpPublisher::RtmpPublisher( publisher : %p )", this);
    
    Init();
}

RtmpPublisher::~RtmpPublisher() {
    FileLog("rtmpdump", "RtmpPublisher::~RtmpPublisher( publisher : %p )", this);
    
    Stop();
}

bool RtmpPublisher::PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::PublishUrl( "
                 "url : %s "
                 ")",
                 url.c_str()
                 );
    
    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    bFlag = mpRtmpDump->PublishUrl(url, recordH264FilePath, recordAACFilePath);
    if( bFlag ) {
        // 开始播放
        mbRunning = true;
        
        mPublishThread.Start(mpPublishRunnable);
        
    } else {
        Stop();
    }
    
    mClientMutex.unlock();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::PublishUrl( "
                 "[Finish], "
                 "url : %s, "
                 "bFlag : %s "
                 ")",
                 url.c_str(),
                 bFlag?"true":"false"
                 );
    
    return bFlag;
}

void RtmpPublisher::Stop() {
    mClientMutex.lock();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::Stop( "
                 "this : %p "
                 ")",
                 this
                 );
    
    if( mbRunning ) {
        mbRunning = false;
        
        // 停止接收
        mpRtmpDump->Stop();
        
        // 停止发布
        mPublishThread.Stop();

        // 清除视频Buffer
        VideoFrame* videoFrame = NULL;
        mVideoBufferList.lock();
        while( !mVideoBufferList.empty() ) {
            videoFrame = (VideoFrame *)mVideoBufferList.front();
            mVideoBufferList.pop_front();
            delete videoFrame;
        }
        mVideoBufferList.unlock();

        while( (videoFrame = (VideoFrame *)mCacheVideoBufferQueue.PopBuffer()) != NULL ) {
            delete videoFrame;
        }
        
        // 清除音频Buffer
        AudioFrame* audioFrame = NULL;
        mAudioBufferList.lock();
        while( !mAudioBufferList.empty() ) {
            audioFrame = (AudioFrame *)mAudioBufferList.front();
            mAudioBufferList.pop_front();
            delete audioFrame;
        }
        mAudioBufferList.unlock();
        
        while( (audioFrame = (AudioFrame *)mCacheAudioBufferQueue.PopBuffer()) != NULL ) {
            delete audioFrame;
        }
    }
    
    mClientMutex.unlock();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::Stop( "
                 "[Finish], "
                 "this : %p "
                 ")",
                 this
                 );
}

void RtmpPublisher::Init() {
    mbRunning = false;
    
    mCacheVideoBufferQueue.SetCacheQueueSize(30);
    mCacheAudioBufferQueue.SetCacheQueueSize(50);
    
    mpPublishRunnable = new PublishRunnable(this);
}

void RtmpPublisher::SendVideoFrame(char* data, int size, u_int32_t timestamp) {
    mClientMutex.lock();
    
    if( mbRunning ) {
        VideoFrame* videoFrame = (VideoFrame *)mCacheVideoBufferQueue.PopBuffer();
        if( !videoFrame ) {
            videoFrame = new VideoFrame();
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "RtmpPublisher::SendVideoFrame( "
                         "[New Video frame], "
                         "videoFrame : %p "
                         ")",
                         videoFrame
                         );
        }
        
        if( videoFrame ) {
            videoFrame->SetBuffer((const unsigned char *)data, size);
            videoFrame->mTimestamp = timestamp;
        }
        
        mVideoBufferList.lock();
        mVideoBufferList.push_back(videoFrame);
        mVideoBufferList.unlock();
    }
    
    mClientMutex.unlock();
}

void RtmpPublisher::SendAudioFrame(
                                   AudioFrameFormat sound_format,
                                   AudioFrameSoundRate sound_rate,
                                   AudioFrameSoundSize sound_size,
                                   AudioFrameSoundType sound_type,
                                   char* data,
                                   int size,
                                   u_int32_t timestamp
                                   ) {
    mClientMutex.lock();
    
    if( mbRunning ) {
        AudioFrame* audioFrame = (AudioFrame *)mCacheAudioBufferQueue.PopBuffer();
        if( !audioFrame ) {
            audioFrame = new AudioFrame();
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "RtmpPublisher::SendAudioFrame( "
                         "[New Audio frame], "
                         "audioFrame : %p "
                         ")",
                         audioFrame
                         );
        }
        
        if( audioFrame ) {
            audioFrame->mFormat = sound_format;
            audioFrame->mSoundRate = sound_rate;
            audioFrame->mSoundSize = sound_size;
            audioFrame->mSoundType = sound_type;
            
            audioFrame->SetBuffer((const unsigned char *)data, size);
            audioFrame->mTimestamp = timestamp;
        }
        
        mAudioBufferList.lock();
        mAudioBufferList.push_back(audioFrame);
        mAudioBufferList.unlock();
    }
    
    mClientMutex.unlock();
}
 
void RtmpPublisher::SetRtmpDump(RtmpDump* rtmpDump) {
    mpRtmpDump = rtmpDump;
}
    
void RtmpPublisher::PublishHandle() {
    // 帧缓存
    VideoFrame* videoFrame = NULL;
    AudioFrame* audioFrame = NULL;
    
    while( mbRunning ) {
        videoFrame = NULL;
        audioFrame = NULL;
        
        // 获取视频帧
        mVideoBufferList.lock();
        if( !mVideoBufferList.empty() ) {
            videoFrame = (VideoFrame *)mVideoBufferList.front();
            mVideoBufferList.pop_front();
        }
        mVideoBufferList.unlock();
        
        // 发送视频帧
        if( videoFrame ) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "RtmpPublisher::PublishHandle( "
                         "[Send Video Frame], "
                         "frame : %p, "
                         "timestamp : %u, "
                         "frameType : 0x%x "
                         ")",
                         videoFrame,
                         videoFrame->mTimestamp,
                         videoFrame->GetBuffer()[0]
                         );
            
            mpRtmpDump->SendVideoFrame((char *)videoFrame->GetBuffer(), videoFrame->mBufferLen, videoFrame->mTimestamp);
            
            // 回收资源
            if( !mCacheVideoBufferQueue.PushBuffer(videoFrame) ) {
                // 归还失败，释放Buffer
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                            "RtmpPublisher::PublishHandle( "
                            "[Delete Video frame], "
                            "videoFrame : %p "
                            ")",
                            videoFrame
                            );
                delete videoFrame;
            }
        }
        
        // 获取音频帧
        mAudioBufferList.lock();
        if( !mAudioBufferList.empty() ) {
            audioFrame = (AudioFrame *)mAudioBufferList.front();
            mAudioBufferList.pop_front();
        }
        mAudioBufferList.unlock();
        
        // 发送音频帧
        if( audioFrame ) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "RtmpPublisher::PublishHandle( "
                         "[Send Audio Frame], "
                         "frame : %p, "
                         "timestamp : %u "
                         ")",
                         audioFrame,
                         audioFrame->mTimestamp
                         );
            
            mpRtmpDump->SendAudioFrame(audioFrame->mFormat,
                                       audioFrame->mSoundRate,
                                       audioFrame->mSoundSize,
                                       audioFrame->mSoundType,
                                       (char *)audioFrame->GetBuffer(),
                                       audioFrame->mBufferLen,
                                       audioFrame->mTimestamp
                                       );
            
            // 回收资源
            if( !mCacheAudioBufferQueue.PushBuffer(audioFrame) ) {
                // 归还失败，释放Buffer
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "RtmpPublisher::PublishHandle( "
                            "[Delete Audio frame], "
                            "audioFrame : %p "
                            ")",
                            audioFrame
                            );
                delete audioFrame;
            }
        }
        
        Sleep(PUBLISH_SLEEP_TIME);
    }
}
}
