//
//  RtmpPublisher.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPublisher.h"

#include "video/VideoFrame.h"
#include "audio/AudioFrame.h"

// 发布休眠
#define PUBLISH_SLEEP_TIME 1

#define VIDEO_BUFFER_COUNT 90
#define AUDIO_BUFFER_COUNT 250

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
    : mClientMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "RtmpPublisher::RtmpPublisher( this : %p )", this);

    Init();
}

RtmpPublisher::~RtmpPublisher() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "RtmpPublisher::~RtmpPublisher( this : %p )", this);

    Stop();

    if (mpPublishRunnable) {
        delete mpPublishRunnable;
        mpPublishRunnable = NULL;
    }
}

bool RtmpPublisher::PublishUrl() {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::PublishUrl( "
                 "this : %p "
                 ")",
                 this);

    mClientMutex.lock();
    if (mbRunning) {
        Stop();
    }

    InitBuffer();

    // 开始播放
    mbRunning = true;

    mPublishThread.Start(mpPublishRunnable);

    bFlag = true;

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::PublishUrl( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void RtmpPublisher::Init() {
    mbRunning = false;

    mCacheVideoBufferQueue.SetCacheQueueSize(VIDEO_BUFFER_COUNT);
    mCacheAudioBufferQueue.SetCacheQueueSize(AUDIO_BUFFER_COUNT);

    mpPublishRunnable = new PublishRunnable(this);
}

void RtmpPublisher::InitBuffer() {
    for (int i = 0; i < VIDEO_BUFFER_COUNT; i++) {
        VideoFrame *videoFrame = new VideoFrame();
        mCacheVideoBufferQueue.PushBuffer(videoFrame);
    }

    for (int i = 0; i < VIDEO_BUFFER_COUNT; i++) {
        AudioFrame *audioFrame = new AudioFrame();
        mCacheAudioBufferQueue.PushBuffer(audioFrame);
    }
}

void RtmpPublisher::Stop() {
    mClientMutex.lock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::Stop( "
                 "this : %p "
                 ")",
                 this);

    if (mbRunning) {
        mbRunning = false;

        // 停止发布
        mPublishThread.Stop();

        // 清除视频Buffer
        VideoFrame *videoFrame = NULL;
        mVideoBufferList.lock();
        while (!mVideoBufferList.empty()) {
            videoFrame = (VideoFrame *)mVideoBufferList.front();
            mVideoBufferList.pop_front();
            delete videoFrame;
        }
        mVideoBufferList.unlock();

        while ((videoFrame = (VideoFrame *)mCacheVideoBufferQueue.PopBuffer()) != NULL) {
            delete videoFrame;
        }

        // 清除音频Buffer
        AudioFrame *audioFrame = NULL;
        mAudioBufferList.lock();
        while (!mAudioBufferList.empty()) {
            audioFrame = (AudioFrame *)mAudioBufferList.front();
            mAudioBufferList.pop_front();
            delete audioFrame;
        }
        mAudioBufferList.unlock();

        while ((audioFrame = (AudioFrame *)mCacheAudioBufferQueue.PopBuffer()) != NULL) {
            delete audioFrame;
        }
    }

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPublisher::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void RtmpPublisher::SendVideoFrame(char *data, int size, u_int32_t timestamp) {
    mClientMutex.lock();

    if (mbRunning) {
        VideoFrame *videoFrame = (VideoFrame *)mCacheVideoBufferQueue.PopBuffer();
        if (!videoFrame) {
            //            videoFrame = new VideoFrame();
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "RtmpPublisher::SendVideoFrame( "
                         "this : %p, "
                         "[Cache Video buffer is full, droped], "
                         "mVideoBufferList : %u "
                         ")",
                         this,
                         mVideoBufferList.size()
                         );
        }

        if (videoFrame) {
            videoFrame->SetBuffer((const unsigned char *)data, size);
            videoFrame->mTimestamp = timestamp;

            mVideoBufferList.lock();
            mVideoBufferList.push_back(videoFrame);
            mVideoBufferList.unlock();
        }
    }

    mClientMutex.unlock();
}

void RtmpPublisher::SendAudioFrame(
    AudioFrameFormat sound_format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type,
    char *data,
    int size,
    u_int32_t timestamp) {
    mClientMutex.lock();

    if (mbRunning) {
        AudioFrame *audioFrame = (AudioFrame *)mCacheAudioBufferQueue.PopBuffer();
        if (!audioFrame) {
            //            audioFrame = new AudioFrame();
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "RtmpPublisher::SendAudioFrame( "
                         "this : %p, "
                         "[Cache Audio buffer is full, droped], "
                         "mAudioBufferList : %u "
                         ")",
                         this,
                         mAudioBufferList.size()
                         );
        }

        if (audioFrame) {
            audioFrame->InitFrame(sound_format, sound_rate, sound_size, sound_type);
            audioFrame->SetBuffer((const unsigned char *)data, size);
            audioFrame->mTimestamp = timestamp;

            mAudioBufferList.lock();
            mAudioBufferList.push_back(audioFrame);
            mAudioBufferList.unlock();
        }
    }

    mClientMutex.unlock();
}

void RtmpPublisher::SetRtmpDump(RtmpDump *rtmpDump) {
    mpRtmpDump = rtmpDump;
}

void RtmpPublisher::PublishHandle() {
    // 帧缓存
    VideoFrame *videoFrame = NULL;
    AudioFrame *audioFrame = NULL;

    while (mbRunning) {
        videoFrame = NULL;
        audioFrame = NULL;

        // 获取视频帧
        mVideoBufferList.lock();
        if (!mVideoBufferList.empty()) {
            videoFrame = (VideoFrame *)mVideoBufferList.front();
            mVideoBufferList.pop_front();
        }
        mVideoBufferList.unlock();

        // 发送视频帧
        if (videoFrame) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "RtmpPublisher::PublishHandle( "
                         "this : %p, "
                         "[Send Video Frame], "
                         "frame : %p, "
                         "timestamp : %u, "
                         "frameType : 0x%x, "
                         "mVideoBufferList : %u "
                         ")",
                         this,
                         videoFrame,
                         videoFrame->mTimestamp,
                         videoFrame->GetBuffer()[0],
                         mVideoBufferList.size()
                         );

            if (mpRtmpDump) {
                mpRtmpDump->SendVideoFrame((char *)videoFrame->GetBuffer(), videoFrame->mBufferLen, videoFrame->mTimestamp);
            }

            // 回收资源
            if (!mCacheVideoBufferQueue.PushBuffer(videoFrame)) {
                // 归还失败，释放Buffer
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "RtmpPublisher::PublishHandle( "
                             "this : %p, "
                             "[Delete Video frame], "
                             "videoFrame : %p "
                             ")",
                             this,
                             videoFrame);
                delete videoFrame;
            }
        }

        // 获取音频帧
        mAudioBufferList.lock();
        if (!mAudioBufferList.empty()) {
            audioFrame = (AudioFrame *)mAudioBufferList.front();
            mAudioBufferList.pop_front();
        }
        mAudioBufferList.unlock();

        // 发送音频帧
        if (audioFrame) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "RtmpPublisher::PublishHandle( "
                         "this : %p, "
                         "[Send Audio Frame], "
                         "frame : %p, "
                         "timestamp : %u, "
                         "mAudioBufferList : %u "
                         ")",
                         this,
                         audioFrame,
                         audioFrame->mTimestamp,
                         mAudioBufferList.size()
                         );

            if (mpRtmpDump) {
                mpRtmpDump->SendAudioFrame(audioFrame->mSoundFormat,
                                           audioFrame->mSoundRate,
                                           audioFrame->mSoundSize,
                                           audioFrame->mSoundType,
                                           (char *)audioFrame->GetBuffer(),
                                           audioFrame->mBufferLen,
                                           audioFrame->mTimestamp);
            }

            // 回收资源
            if (!mCacheAudioBufferQueue.PushBuffer(audioFrame)) {
                // 归还失败，释放Buffer
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "RtmpPublisher::PublishHandle( "
                             "this : %p, "
                             "[Delete Audio frame], "
                             "audioFrame : %p "
                             ")",
                             this,
                             audioFrame);
                delete audioFrame;
            }
        }
        
        Sleep(PUBLISH_SLEEP_TIME);
    }
}
}
