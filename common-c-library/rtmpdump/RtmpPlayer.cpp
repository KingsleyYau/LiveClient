//
//  RtmpPlayer.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPlayer.h"

// 默认视频数据播放缓存(毫秒)
#define PLAY_CACHE_DEFAULT_MS 1000

// 最大视频数据缓存数量(帧个数)
#define PLAYVIDEO_CACHE_MAX_NUM 60

// 播放休眠
#define PLAY_SLEEP_TIME 1
// 帧延迟丢弃值(MS), 如果由于CPU卡顿, 可能导致音视频不同步的差距值(音频延迟)
#define PLAY_DELAY_DROP_TIME 300
// 帧延迟断开值(MS)
#define PLAY_DELAY_DISCONNECT_TIME 5000
//// 无效的时间戳
//#define INVALID_TIMESTAMP 0xFFFFFFFF
// 音视频同步间隔(MS)
#define AUDIO_DIFF_VIDEO_TIMESTAMP 300

// 视频警告缓冲(帧数)
#define VIDEO_WARN_FRAME_COUNT 90
// 视频最大缓冲(帧数)
#define VIDEO_MAX_FRAME_COUNT 120
// 音频警告缓冲(帧数)
#define AUDIO_WARN_FRAME_COUNT 200
// 音频最大缓冲(帧数)
#define AUDIO_MAX_FRAME_COUNT 350
namespace coollive {
class PlayVideoRunnable : public KRunnable {
  public:
    PlayVideoRunnable(RtmpPlayer *container) {
        mContainer = container;
    }
    virtual ~PlayVideoRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->PlayVideoRunnableHandle();
    }

  private:
    RtmpPlayer *mContainer;
};

class PlayAudioRunnable : public KRunnable {
  public:
    PlayAudioRunnable(RtmpPlayer *container) {
        mContainer = container;
    }
    virtual ~PlayAudioRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->PlayAudioRunnableHandle();
    }

  private:
    RtmpPlayer *mContainer;
};

RtmpPlayer::RtmpPlayer()
    : mClientMutex(KMutex::MutexType_Recursive),
      mPlayThreadMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "RtmpPlayer::RtmpPlayer( this : %p )", this);
    Init();
}

RtmpPlayer::RtmpPlayer(
    RtmpDump *rtmpDump,
    RtmpPlayerCallback *callback)
    : mClientMutex(KMutex::MutexType_Recursive),
      mPlayThreadMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "RtmpPlayer::RtmpPlayer( this : %p )", this);
    Init();

    mpRtmpDump = rtmpDump;
    mpRtmpPlayerCallback = callback;

    mbNoCacheLimit = false;
}

RtmpPlayer::~RtmpPlayer() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "RtmpPlayer::~RtmpPlayer( this : %p )", this);

    Stop();

    FrameBuffer *buffer = NULL;
    while ((buffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer())) {
        delete buffer;
    }

    if (mpPlayVideoRunnable) {
        delete mpPlayVideoRunnable;
    }

    if (mpPlayAudioRunnable) {
        delete mpPlayAudioRunnable;
    }
}

bool RtmpPlayer::PlayUrl(const string &recordFilePath) {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPlayer::PlayUrl( "
                 "this : %p "
                 ")",
                 this);

    mClientMutex.lock();
    if (mbRunning) {
        Stop();
    }

    bFlag = true;
    if (bFlag) {
        // 开始播放
        mbRunning = true;
        
        mPlayVideoThread.Start(mpPlayVideoRunnable);
        mPlayAudioThread.Start(mpPlayAudioRunnable);

    } else {
        Stop();
    }

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPlayer::PlayUrl( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void RtmpPlayer::Stop() {
    mClientMutex.lock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPlayer::Stop( "
                 "this : %p "
                 ")",
                 this);

    if (mbRunning) {
        mbRunning = false;

        // 停止播放
        mPlayVideoThread.Stop();
        mPlayAudioThread.Stop();

        // 清除缓存
        FrameBuffer *frame = NULL;

        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "RtmpPlayer::Stop( "
                     "this : %p, "
                     "mVideoBufferList() : %d, "
                     "mAudioBufferList() : %d "
                     ")",
                     this,
                     mVideoBufferList.size(),
                     mAudioBufferList.size());

        // 清除视频缓存帧
        mVideoBufferList.lock();
        while (!mVideoBufferList.empty()) {
            frame = mVideoBufferList.front();

            if (frame != NULL) {
                if (mpRtmpPlayerCallback) {
                    mpRtmpPlayerCallback->OnDropVideoFrame(this, frame->mpFrame, frame->mTS);
                }

                // 回收资源
                if (!mCacheBufferQueue.PushBuffer(frame)) {
                    // 归还失败，释放Buffer
                    delete frame;
                }

                mVideoBufferList.pop_front();

            } else {
                break;
            }
        }
        mVideoBufferList.unlock();

        // 清除音视频缓存帧
        mAudioBufferList.lock();
        while (!mAudioBufferList.empty()) {
            frame = mAudioBufferList.front();

            if (frame != NULL) {
                if (mpRtmpPlayerCallback) {
                    mpRtmpPlayerCallback->OnDropAudioFrame(this, frame->mpFrame, frame->mTS);
                }

                // 回收资源
                if (!mCacheBufferQueue.PushBuffer(frame)) {
                    // 归还失败，释放Buffer
                    delete frame;
                }

                mAudioBufferList.pop_front();

            } else {
                break;
            }
        }
        mAudioBufferList.unlock();

        // 清除内存池Buffer
        while ((frame = (FrameBuffer *)mCacheBufferQueue.PopBuffer()) != NULL) {
            delete frame;
        }

        // 还原参数
        mIsWaitCache = true;

        mStartPlayTime = 0;
        mbVideoStartPlay = false;
        mbAudioStartPlay = false;

        mVideoFrontTS = INVALID_TIMESTAMP;
        mVideoBackTS = INVALID_TIMESTAMP;
        mAudioFrontTS = INVALID_TIMESTAMP;
        mAudioBackTS = INVALID_TIMESTAMP;
    }

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpPlayer::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void RtmpPlayer::SetRtmpDump(RtmpDump *rtmpDump) {
    mpRtmpDump = rtmpDump;
}

void RtmpPlayer::SetCallback(RtmpPlayerCallback *callback) {
    mpRtmpPlayerCallback = callback;
}

void RtmpPlayer::SetCacheMS(unsigned int cacheMS) {
    mCacheMS = cacheMS;
}

int RtmpPlayer::CahceMS() const {
    return mCacheMS;
}

void RtmpPlayer::SetCacheNoLimit(bool bNoCacheLimit) {
    mbNoCacheLimit = bNoCacheLimit;
}

void RtmpPlayer::SetPlaybackRate(float playBackRate) {
    mPlaybackRate = playBackRate;
    mAudioPlaybackRateChange = true;
    mVideoPlaybackRateChange = true;
}

void RtmpPlayer::PlayVideoRunnableHandle() {
    PlayFrame(false);
}

void RtmpPlayer::PlayAudioRunnableHandle() {
    PlayFrame(true);
}

void RtmpPlayer::PushVideoFrame(void *frame, int64_t ts) {
    FileLevelLog(
        "rtmpdump",
        KLog::LOG_MSG,
        "RtmpPlayer::PushVideoFrame( "
        "this : %p, "
        "frame : %p, "
        "ts : %lld, "
        "bufferListSize : %u "
        ")",
        this,
        frame,
        ts,
        mVideoBufferList.size());

    mPlayThreadMutex.lock();
    mbShowNoCacheLog = false;
    mPlayThreadMutex.unlock();

    if ( mbRunning ) {
        if (mbCacheFrame) {
            // 放到播放线程
            FrameBuffer *frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
            if (!frameBuffer) {
                frameBuffer = new FrameBuffer();
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_WARNING,
                    "RtmpPlayer::PushVideoFrame( "
                    "this : %p, "
                    "[New Video Frame Buffer], "
                    "ts : %lld, "
                    "bufferListSize : %u "
                    ")",
                    this,
                    ts,
                    mVideoBufferList.size()
                    );
            }

            if (frameBuffer) {
                frameBuffer->mpFrame = (void *)frame;
                frameBuffer->mTS = ts;
            }

            mVideoBufferList.lock();

            if (!mbNoCacheLimit) {
                if (mVideoBufferList.size() > VIDEO_WARN_FRAME_COUNT) {
                    FileLevelLog(
                        "rtmpdump",
                        KLog::LOG_WARNING,
                        "RtmpPlayer::PushVideoFrame( "
                        "this : %p, "
                        "[Video Buffer Size Warning], "
                        "ts : %lld, "
                        "bufferListSize : %u "
                        ")",
                        this,
                        ts,
                        mVideoBufferList.size());
                }
            }

    //        mVideoBufferList.push_back(frameBuffer);
            if ( mVideoBufferList.empty() ) {
                mVideoBufferList.push_back(frameBuffer);
            } else {
                /**
                 rbegin = last element
                 end = last element + 1
                 rbegin.base = end
                 */
                for(FrameBufferList::reverse_iterator itr = mVideoBufferList.rbegin(); itr != mVideoBufferList.rend(); itr++) {
                    if ( frameBuffer->mTS > (*itr)->mTS ) {
                        FrameBufferList::iterator base = (itr).base();
                        mVideoBufferList.insert(base, frameBuffer);
                        break;
                    }
                }
            }
            mVideoFrontTS = mVideoBufferList.front()->mTS;
            mVideoBackTS = mVideoBufferList.back()->mTS;
            mVideoBufferList.unlock();

        } else {
            // 直接播放
            FrameBuffer frameBuffer((void *)frame, ts);
            PlayVideoFrame(&frameBuffer);
        }
    } else {
        // 直接丢弃
        FrameBuffer frameBuffer((void *)frame, ts);
        DropVideoFrame(&frameBuffer);
    }
}

void RtmpPlayer::PushAudioFrame(void *frame, int64_t ts) {
    FileLevelLog(
        "rtmpdump",
        KLog::LOG_MSG,
        "RtmpPlayer::PushAudioFrame( "
        "this : %p, "
        "frame : %p, "
        "ts : %lld, "
        "bufferListSize : %u "
        ")",
        this,
        frame,
        ts,
        mAudioBufferList.size());

    mPlayThreadMutex.lock();
    mbShowNoCacheLog = false;
    mPlayThreadMutex.unlock();

    if ( mbRunning ) {
        if (mbCacheFrame&& mbRunning) {
            // 放到播放线程
            FrameBuffer *frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
            if (!frameBuffer) {
                frameBuffer = new FrameBuffer();
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_WARNING,
                    "RtmpPlayer::PushAudioFrame( "
                    "this : %p, "
                    "[New Audio Frame Buffer], "
                    "ts : %lld, "
                    "bufferListSize : %u "
                    ")",
                    this,
                    ts,
                    mAudioBufferList.size());
            }

            if (frameBuffer) {
                frameBuffer->mpFrame = (void *)frame;
                frameBuffer->mTS = ts;
            }

            mAudioBufferList.lock();

            if (mAudioBufferList.size() > AUDIO_WARN_FRAME_COUNT) {
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_WARNING,
                    "RtmpPlayer::PushAudioFrame( "
                    "this : %p, "
                    "[Audio Buffer Size Warning], "
                    "ts : %lld, "
                    "bufferListSize : %u "
                    ")",
                    this,
                    ts,
                    mAudioBufferList.size());
            }

            mAudioBufferList.push_back(frameBuffer);
            mAudioFrontTS = mAudioBufferList.front()->mTS;
            mAudioBackTS = mAudioBufferList.back()->mTS;
            mAudioBufferList.unlock();

        } else {
            // 直接播放
            FrameBuffer frameBuffer((void *)frame, ts);
            PlayAudioFrame(&frameBuffer);
        }
    } else {
        // 直接丢弃
        FrameBuffer frameBuffer((void *)frame, ts);
        DropVideoFrame(&frameBuffer);
    }
}

RtmpPlayerCallback *RtmpPlayer::GetCallback() {
    return mpRtmpPlayerCallback;
}

size_t RtmpPlayer::GetVideBufferSize() {
    size_t size = 0;
    mVideoBufferList.lock();
    size = mVideoBufferList.size();
    mVideoBufferList.unlock();
    return size;
}

void RtmpPlayer::Init() {
    mbRunning = false;

    mCacheMS = PLAY_CACHE_DEFAULT_MS;
    mbCacheFrame = true;
    mbSyncFrame = true;

    mStartPlayTime = 0;
    mIsWaitCache = true;
    
    mpRtmpDump = NULL;
    mpRtmpPlayerCallback = NULL;

    mCacheBufferQueue.SetCacheQueueSize(200);
    
    mPlaybackRate = 1.0f;
    mAudioPlaybackRateChange = false;
    mVideoPlaybackRateChange = false;
    
    mpPlayVideoRunnable = new PlayVideoRunnable(this);
    mpPlayAudioRunnable = new PlayAudioRunnable(this);

    mbShowNoCacheLog = false;
    mbVideoStartPlay = false;
    mbAudioStartPlay = false;

    mVideoFrontTS = INVALID_TIMESTAMP;
    mVideoBackTS = INVALID_TIMESTAMP;
    mAudioFrontTS = INVALID_TIMESTAMP;
    mAudioBackTS = INVALID_TIMESTAMP;
}

bool RtmpPlayer::IsCacheEnough() {
    bool bFlag = false;

    int64_t startVideoTS = 0;
    int64_t endVideoTS = 0;

    int64_t startAudioTS = 0;
    int64_t endAudioTS = 0;

    int64_t startTS = 0;
    int64_t endTS = 0;

    FrameBuffer *videoFrame = NULL;
    FrameBuffer *audioFrame = NULL;

    bool bPop = true;

    mVideoBufferList.lock();
    if (!mVideoBufferList.empty()) {
        // 清空旧的Buffer
        while (bPop) {
            videoFrame = mVideoBufferList.front();
            if (videoFrame->mTS > mVideoBufferList.back()->mTS) {
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_WARNING,
                    "RtmpPlayer::IsCacheEnough( "
                    "this : %p, "
                    "[Pop Extra Video Frame], "
                    "videoFrameFront->mTS : %lld, "
                    "videoFrameBack->mTS : %lld "
                    ")",
                    this,
                    videoFrame->mTS,
                    mVideoBufferList.back()->mTS);

                // 回收资源
                if (!mCacheBufferQueue.PushBuffer(videoFrame)) {
                    delete videoFrame;
                }
                mVideoBufferList.pop_front();
            } else {
                break;
            }
        }

        // 计算新的TS
        videoFrame = mVideoBufferList.front();
        startVideoTS = videoFrame->mTS;
        if ((startTS == 0) || startTS > startVideoTS) {
            startTS = videoFrame->mTS;
        }

        videoFrame = mVideoBufferList.back();
        endVideoTS = videoFrame->mTS;
        if (endTS < endVideoTS) {
            endTS = videoFrame->mTS;
        }
    }
    mVideoBufferList.unlock();

    mAudioBufferList.lock();
    if (!mAudioBufferList.empty()) {
        // 清空旧的Buffer
        while (bPop) {
            audioFrame = mAudioBufferList.front();
            if (audioFrame->mTS > mAudioBufferList.back()->mTS) {
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_MSG,
                    "RtmpPlayer::IsCacheEnough( "
                    "this : %p, "
                    "[Pop Extra Audio Frame], "
                    "audioFrameFront->mTS : %u, "
                    "audioFrameBack->mTS : %u "
                    ")",
                    this,
                    audioFrame->mTS,
                    mAudioBufferList.back()->mTS);

                // 回收资源
                if (!mCacheBufferQueue.PushBuffer(audioFrame)) {
                    delete audioFrame;
                }
                mAudioBufferList.pop_front();
            } else {
                break;
            }
        }

        audioFrame = mAudioBufferList.front();
        startAudioTS = audioFrame->mTS;
        if ((startTS == 0) || startTS > startAudioTS) {
            startTS = audioFrame->mTS;
        }

        audioFrame = mAudioBufferList.back();
        endAudioTS = audioFrame->mTS;
        if (endTS < endAudioTS) {
            endTS = audioFrame->mTS;
        }
    }
    mAudioBufferList.unlock();

    //	mPlayThreadMutex.lock();
    if ((endTS - startTS >= mCacheMS || mAudioBufferList.size() > 150 || mVideoBufferList.size() > 90)) {
        // 缓存足够, 判断音频先开始还是视频先开始
        if (bPop) {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_MSG,
                "RtmpPlayer::IsCacheEnough( "
                "this : %p, "
                "startVideoTS : %d, "
                "endVideoTS : %d, "
                "startAudioTS : %d, "
                "endAudioTS : %d, "
                "startTS : %d, "
                "endTS : %d, "
                "mVideoBufferList.size() : %d, "
                "mAudioBufferList.size() : %d "
                ")",
                this,
                startVideoTS,
                endVideoTS,
                startAudioTS,
                endAudioTS,
                startTS,
                endTS,
                mVideoBufferList.size(),
                mAudioBufferList.size());
        }

        bFlag = true;
    }
    //	mPlayThreadMutex.unlock();

    return bFlag;
}

bool RtmpPlayer::IsRestStream(FrameBuffer *frame, int64_t preTS) {
    bool bFlag = false;

    if (frame) {
        /**
         * 需要同步播放时间
         * 1.本地ts比服务器要大
         */
        if (preTS != INVALID_TIMESTAMP && preTS > frame->mTS) {
            bFlag = true;
        }
    }

    return bFlag;
}

bool RtmpPlayer::IsPlay(bool isAudio) {
    bool bFlag = false;

    long long curTime = (long long)getCurrentTime();
    if (mbSyncFrame) {
        // 需要音视频同步
        if (isAudio) {
            // 音频未开播
            if (!mbAudioStartPlay) {
                // 计算音视频开播差值
                FrameBuffer *audioFrame = NULL;
                int64_t audioTS = INVALID_TIMESTAMP;
                FrameBuffer *videoFrame = NULL;
                int64_t videoTS = INVALID_TIMESTAMP;

                videoTS = mVideoFrontTS;

                // 下一帧播放的视频时间戳
                if (videoTS != INVALID_TIMESTAMP) {
                    // 已经缓存视频, 比较音视频时间戳
                    mAudioBufferList.lock();
                    if (!mAudioBufferList.empty()) {
                        audioFrame = mAudioBufferList.front();
                        audioTS = audioFrame->mTS;

                        FileLevelLog("rtmpdump",
                                     KLog::LOG_STAT,
                                     "RtmpPlayer::IsPlay( "
                                     "this : %p, "
                                     "[Sync Audio], "
                                     "audioTS : %d, "
                                     "videoTS : %d "
                                     ")",
                                     this,
                                     audioTS,
                                     videoTS);

                        // 视频时间戳不在重置中
                        if (mVideoBackTS >= mVideoFrontTS) {
                            if (audioTS <= videoTS - AUDIO_DIFF_VIDEO_TIMESTAMP) {
                                // 音频延迟太大, 丢弃
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_WARNING,
                                             "RtmpPlayer::IsPlay( "
                                             "this : %p, "
                                             "[Sync Audio to drop], "
                                             "audioTS : %d, "
                                             "videoTS : %d "
                                             ")",
                                             this,
                                             audioTS,
                                             videoTS);

                                DropAudioFrame(audioFrame);
                                mAudioBufferList.pop_front();

                                // 回收资源
                                if (!mCacheBufferQueue.PushBuffer(audioFrame)) {
                                    // 归还失败，释放Buffer
                                    FileLog("rtmpdump",
                                            "RtmpPlayer::IsPlay( "
                                            "this : %p, "
                                            "[Delete Audio frame], "
                                            "frame : %p "
                                            ")",
                                            this,
                                            audioFrame);
                                    delete audioFrame;
                                }

                            } else if (audioTS <= videoTS) {
                                // 音频的时间戳已经追上视频, 开始播放
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_WARNING,
                                             "RtmpPlayer::IsPlay( "
                                             "this : %p, "
                                             "[Sync Audio to play], "
                                             "audioTS : %d, "
                                             "videoTS : %d "
                                             ")",
                                             this,
                                             audioTS,
                                             videoTS);
                                bFlag = true;
                                mbAudioStartPlay = true;
                            }
                        } else {
                            // 视频时间戳重置中
                            FileLevelLog("rtmpdump",
                                         KLog::LOG_WARNING,
                                         "RtmpPlayer::IsPlay( "
                                         "this : %p, "
                                         "[Sync Audio for Video ts reset], "
                                         "mVideoFrontTS : %d, "
                                         "mVideoBackTS : %d "
                                         ")",
                                         this,
                                         mVideoFrontTS,
                                         mVideoBackTS);
                        }
                    }
                    mAudioBufferList.unlock();

                } else {
                    // 没有视频频
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "RtmpPlayer::IsPlay( "
                                 "this : %p, "
                                 "[Sync Audio to play for NO Video frame] "
                                 ")",
                                 this);
                    bFlag = true;
                    mbAudioStartPlay = true;
                }
            } else {
                bFlag = true;
            }

        } else {
            // 视频未开播
            if (!mbVideoStartPlay) {
                // 计算视频开播差值
                FrameBuffer *audioFrame = NULL;
                int64_t audioTS = INVALID_TIMESTAMP;
                FrameBuffer *videoFrame = NULL;
                int64_t videoTS = INVALID_TIMESTAMP;

                audioTS = mAudioFrontTS;

                // 下一帧播放的音频时间戳
                if (audioTS != INVALID_TIMESTAMP) {
                    // 已经缓存音频, 比较音视频时间戳
                    mVideoBufferList.lock();
                    if (!mVideoBufferList.empty()) {
                        videoFrame = mVideoBufferList.front();
                        videoTS = videoFrame->mTS;

                        FileLevelLog("rtmpdump",
                                     KLog::LOG_STAT,
                                     "RtmpPlayer::IsPlay( "
                                     "this : %p, "
                                     "[Sync Video], "
                                     "audioTS : %lld, "
                                     "videoTS : %lld "
                                     ")",
                                     this,
                                     audioTS,
                                     videoTS);

                        // 音频时间戳不在重置中
                        if (mAudioBackTS >= mAudioFrontTS) {
                            if (videoTS <= audioTS - AUDIO_DIFF_VIDEO_TIMESTAMP) {
                                // 视频延迟太大, 丢弃
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_WARNING,
                                             "RtmpPlayer::IsPlay( "
                                             "this : %p, "
                                             "[Sync Video to drop], "
                                             "audioTS : %lld, "
                                             "videoTS : %lld "
                                             ")",
                                             this,
                                             audioTS,
                                             videoTS);

                                DropVideoFrame(videoFrame);
                                mVideoBufferList.pop_front();

                                // 回收资源
                                if (!mCacheBufferQueue.PushBuffer(videoFrame)) {
                                    // 归还失败，释放Buffer
                                    FileLog("rtmpdump",
                                            "RtmpPlayer::IsPlay( "
                                            "this : %p, "
                                            "[Delete Video frame], "
                                            "videoFrame : %p "
                                            ")",
                                            this,
                                            videoFrame);
                                    delete videoFrame;
                                }

                            } else if (videoTS <= audioTS) {
                                // 视频的时间戳已经追上音频
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_WARNING,
                                             "RtmpPlayer::IsPlay( "
                                             "this : %p, "
                                             "[Sync Video to play], "
                                             "audioTS : %lld, "
                                             "videoTS : %lld "
                                             ")",
                                             this,
                                             audioTS,
                                             videoTS);
                                bFlag = true;
                                mbVideoStartPlay = true;
                            }
                        } else {
                            // 音频时间戳重置中
                            FileLevelLog("rtmpdump",
                                         KLog::LOG_WARNING,
                                         "RtmpPlayer::IsPlay( "
                                         "this : %p, "
                                         "[Sync Video for Audio ts reset], "
                                         "mAudioFrontTS : %lld, "
                                         "mAudioBackTS : %lld "
                                         ")",
                                         this,
                                         mAudioFrontTS,
                                         mAudioBackTS);
                        }
                    }
                    mVideoBufferList.unlock();
                } else {
                    // 没有音频
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "RtmpPlayer::IsPlay( "
                                 "this : %p, "
                                 "[Sync Video to play for NO Audio frame] "
                                 ")",
                                 this);

                    bFlag = true;
                    mbVideoStartPlay = true;
                }
            } else {
                bFlag = true;
            }
        }

    } else {
        // 不需要音视频同步
        bFlag = true;

        if (isAudio) {
            mbAudioStartPlay = true;
        } else {
            mbVideoStartPlay = true;
        }
    }

    return bFlag;
}

void RtmpPlayer::NoCacheFrame() {
    // 已经没有缓存数据，等待缓存
    mVideoBufferList.lock();
    mAudioBufferList.lock();
    if (mVideoBufferList.size() == 0 && mAudioBufferList.size() == 0) {
        if (!mbShowNoCacheLog) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "RtmpPlayer::NoCacheFrame( "
                         "this : %p, "
                         "mCacheMS : %u "
                         ")",
                         this,
                         mCacheMS);
            mbShowNoCacheLog = true;
        }
    }
    mAudioBufferList.unlock();
    mVideoBufferList.unlock();
}

void RtmpPlayer::PlayFrame(bool isAudio) {
    // 帧缓存
    FrameBuffer *frame = NULL;
    FrameBufferList *bufferList = NULL;

    int bufferMaxCount = 0;
    if (isAudio) {
        // 播放音频
        bufferList = &mAudioBufferList;
        // 设置最大缓冲
        bufferMaxCount = AUDIO_MAX_FRAME_COUNT;

    } else {
        // 播放视频
        bufferList = &mVideoBufferList;
        // 设置最大缓冲
        bufferMaxCount = VIDEO_MAX_FRAME_COUNT;
    }

    // 开始播放时间
    long long startTime = 0;
    // 上一帧视频播放时间
    long long preTime = 0;
    // 开始播放帧时间戳
    int64_t startTS = INVALID_TIMESTAMP;
    // 上一帧视频播放时间戳
    int64_t preTS = INVALID_TIMESTAMP;

    // 由于播放操作导致的时间差
    int64_t handleDelay = 0;
    // 是否需要释放CPU
    bool bSleep = true;
    // 缓冲是否足够
    bool bCacheEnough = false;

    while (mbRunning) {
        bSleep = true;

        // 判断当前缓冲是否已经超过最大值
        if (bufferList->size() > bufferMaxCount) {
            if (mpRtmpPlayerCallback) {
                mpRtmpPlayerCallback->OnOverMaxBufferFrameCount(this);
            }
        }

        // 判断是否需要缓存
        mPlayThreadMutex.lock();
        if (mIsWaitCache) {
            // 这里会pop掉多余的音视频帧
            bCacheEnough = IsCacheEnough();
            if (bCacheEnough) {
                // 音频或者视频缓存成功, 马上开始播放
                mIsWaitCache = false;

                // 开播时间
                mStartPlayTime = getCurrentTime();

                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "RtmpPlayer::PlayFrame( "
                             "this : %p, "
                             "[Cache %s enough], "
                             "mCacheMS : %u, "
                             "mStartPlayTime : %lld, "
                             "bufferListSize : %u "
                             ")",
                             this,
                             isAudio ? "Audio" : "Video",
                             mCacheMS,
                             mStartPlayTime,
                             bufferList->size());
            }

            mPlayThreadMutex.unlock();

        } else {
            mPlayThreadMutex.unlock();

            // 不用等待缓存
            bool bNoCache = false;
            bufferList->lock();
            if (!bufferList->empty()) {
                frame = bufferList->front();

                // 是否需要重置时间戳
                if (IsRestStream(frame, preTS)) {
                    // 重新开始缓存
                    //                    mPlayThreadMutex.lock();
                    //                    mIsWaitCache = true;
                    //                    mPlayThreadMutex.unlock();

//                    FileLevelLog("rtmpdump",
//                                 KLog::LOG_WARNING,
//                                 "RtmpPlayer::PlayFrame( "
//                                 "this : %p, "
//                                 "[Reset %s Start TS], "
//                                 "startTime : %lld, "
//                                 "frame->mTS : %u, "
//                                 "preTS : %u, "
//                                 "bufferListSize : %u "
//                                 ")",
//                                 this,
//                                 isAudio ? "Audio" : "Video",
//                                 startTime,
//                                 frame->mTS,
//                                 preTS,
//                                 bufferList->size());

                    // 重置上帧时间戳
                    preTS = INVALID_TIMESTAMP;

                    if (mpRtmpPlayerCallback) {
                        if (isAudio) {
                            mpRtmpPlayerCallback->OnResetAudioStream(this);
                        } else {
                            mpRtmpPlayerCallback->OnResetVideoStream(this);
                        }
                    }

                } else {
                    // 是否需要播放
                    if (IsPlay(isAudio)) {
                        // 当前时间
                        long long curTime = (long long)getCurrentTime();
                        bool *playbackChange = isAudio?&mAudioPlaybackRateChange:&mVideoPlaybackRateChange;
                        if (preTS == INVALID_TIMESTAMP || *playbackChange) {
                            // 重置开始播放时间
                            startTime = curTime;
                            preTime = startTime;

                            // 重置开始帧时间
                            startTS = frame->mTS;
                            // 重置上次帧时间
                            preTS = startTS;

                            *playbackChange = false;
                            
                            FileLevelLog("rtmpdump",
                                         KLog::LOG_WARNING,
                                         "RtmpPlayer::PlayFrame( "
                                         "this : %p, "
                                         "[Start Play %s], "
                                         "startTime : %lld, "
                                         "startTS : %lld, "
                                         "rate : %.1f, "
                                         "bufferListSize : %u "
                                         ")",
                                         this,
                                         isAudio ? "Audio" : "Video",
                                         startTime,
                                         startTS,
                                         mPlaybackRate,
                                         bufferList->size());
                        }

                        // 本地两帧播放时间差
                        int64_t deltaTime = (int)(curTime - preTime);
                        // 两帧时间差
                        int64_t deltaTS = (frame->mTS - preTS) / mPlaybackRate;
                        // 总播放时间差
                        int64_t deltaTotalTime = (int)(curTime - startTime);
                        // 总帧时间差
                        int64_t deltaTotalTS = (frame->mTS - startTS) / mPlaybackRate;
                        // 是否丢帧
                        bool bDropFrame = false;
                        // 是否断开
                        bool bDisconnect = false;

                        // 帧延迟(总播放时间 - 总帧时间差)
                        int64_t delay = deltaTotalTime - deltaTotalTS;
                        
                        if (deltaTS > 0) {
                            if (delay > 0) {
                                // 播放延迟, 如果是解码能力或者网络不足, 可以通知服务器降低视频质量(码率/帧率/分辨率)
                                if (delay > PLAY_DELAY_DROP_TIME) {
                                    // 播放延迟总延迟大于允许值, 丢弃
                                    bDropFrame = true;
                                }

                                // 播放延迟太大, 断开连接
                                if (delay > PLAY_DELAY_DISCONNECT_TIME) {
                                    bDisconnect = true;
                                }
                            }
                        }
                        
//                        FileLevelLog("rtmpdump",
//                                     KLog::LOG_MSG,
//                                     "RtmpPlayer::PlayFrame( "
//                                     "[Get %s Frame], "
//                                     "ts : %lld, "
//                                     "deltaTime : %lld, "
//                                     "deltaTS : %lld, "
//                                     "delay : %lld, "
//                                     "bufferListSize : %d "
//                                     ")",
//                                     isAudio?"Audio":"Video",
//                                     frame->mTS,
//                                     deltaTime,
//                                     deltaTS,
//                                     delay,
//                                     bufferList->size()
//                                     );

                        bool bHandleFrame = false;
                        if (!bDropFrame) {
                            /**
                             * 判断是否到时间播放
                             * 1.第一帧(deltaTS == 0)
                             * 2.(总播放时间 - 总帧时间戳 > 帧时间戳差)
                             */
                            int delta = 1.0 * (deltaTS - delay);
                            if (isAudio) {
                                if ((deltaTS == 0) || (deltaTime >= delta) /*delay > (deltaTS - 2 * PLAY_SLEEP_TIME)*/) {
                                    PlayAudioFrame(frame);
                                    bHandleFrame = true;
                                }
                            } else {
                                if ((deltaTS == 0) || (deltaTime >= delta) /*delay > (deltaTS - 2 * PLAY_SLEEP_TIME)*/) {
                                    PlayVideoFrame(frame);
                                    bHandleFrame = true;
                                }
                            }
//                            if ((deltaTS == 0) || (deltaTime >= delta) /*delay > (deltaTS - 2 * PLAY_SLEEP_TIME)*/) {
//                                // 播放帧
//                                if (isAudio) {
//                                    PlayAudioFrame(frame);
//                                } else {
//                                    PlayVideoFrame(frame);
//                                }
//
//                                bHandleFrame = true;
//                            }

                        } else {
                            // 本地丢帧
                            if (isAudio) {
                                DropAudioFrame(frame);
                            } else {
                                DropVideoFrame(frame);
                            }

                            bHandleFrame = true;
                        }

                        if (bHandleFrame) {
                            // 播放完成时间
                            long long handleFinishTime = (long long)getCurrentTime();
                            // 计算播放用时
                            int64_t handleTime = (int)(handleFinishTime - curTime);

                            // 丢弃帧不处理, 播放帧才处理
                            if (!bDropFrame) {
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_MSG,
                                             "RtmpPlayer::PlayFrame( "
                                             "this : %p, "
                                             "[Play %s Frame], "
                                             "frame : %p, "
                                             "ts : %lld, "
                                             "handleTime : %lld, "
                                             "deltaTime : %lld, "
                                             "deltaTS : %lld, "
                                             "delay : %lld, "
                                             "deltaTotalTime : %lld, "
                                             "deltaTotalTS : %lld, "
                                             "rate : %.1f, "
                                             "bufferListSize : %d "
                                             ")",
                                             this,
                                             isAudio ? "Audio" : "Video",
                                             frame->mpFrame,
                                             frame->mTS,
                                             handleTime,
                                             deltaTime,
                                             deltaTS,
                                             delay,
                                             deltaTotalTime,
                                             deltaTotalTS,
                                             mPlaybackRate,
                                             bufferList->size());
                            } else {
                                // 丢帧不需要休眠，直接处理下一帧数据
                                FileLevelLog("rtmpdump",
                                             KLog::LOG_MSG,
                                             "RtmpPlayer::PlayFrame( "
                                             "this : %p, "
                                             "[Drop %s Frame], "
                                             "frame : %p, "
                                             "ts : %lld, "
                                             "handleTime : %lld, "
                                             "deltaTime : %lld, "
                                             "deltaTS : %lld, "
                                             "delay : %lld, "
                                             "deltaTotalTime : %lld, "
                                             "deltaTotalTS : %lld, "
                                             "bufferListSize : %d "
                                             ")",
                                             this,
                                             isAudio ? "Audio" : "Video",
                                             frame->mpFrame,
                                             frame->mTS,
                                             handleTime,
                                             deltaTime,
                                             deltaTS,
                                             delay,
                                             deltaTotalTime,
                                             deltaTotalTS,
                                             bufferList->size());
                            }

                            // 比较处理用时和帧时长
                            if (deltaTS > 0 && handleTime >= deltaTS) {
                                // 播放用时大于帧时长, 发生延迟
                                handleDelay = handleTime - deltaTS;
                            }

                            if (isAudio) {
                                // 如果音频帧时间戳差大于30, 需要重置音频播放器, 否者iOS播放器有问题
//                                if (deltaTS > 30) {
//                                    if (mpRtmpPlayerCallback) {
//                                        mpRtmpPlayerCallback->OnResetAudioStream(this);
//                                    }
//                                }
                            }

                            // 队列去除
                            bufferList->pop_front();

                            // 更新最后一帧播放开始时间
                            preTime = curTime; // - frameDelay;
                            preTS = frame->mTS;

                            // 回收资源
                            if (!mCacheBufferQueue.PushBuffer(frame)) {
                                // 归还失败，释放Buffer
                                FileLog("rtmpdump",
                                        "RtmpPlayer::PlayFrame( "
                                        "this : %p, "
                                        "[Delete %s frame], "
                                        "frame : %p "
                                        ")",
                                        this,
                                        isAudio ? "Audio" : "Video",
                                        frame);
                                delete frame;
                            }
                        }

                        if (bDisconnect) {
                            if (mpRtmpPlayerCallback) {
                                mpRtmpPlayerCallback->OnDelayMaxTime(this);
                            }
                        }
                    }
                }
    		} else {
    			// 已经没有缓存数据
                bNoCache = true;
    		}
    		bufferList->unlock();
            
            if( bNoCache ) {
                NoCacheFrame();
            }
    	}

        if( bSleep ) {
            Sleep(PLAY_SLEEP_TIME);
        }
    }

}

void RtmpPlayer::PlayVideoFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PlayVideoFrame( "
//            "ts : %d "
//            ")",
//            frame->mTS
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnPlayVideoFrame(this, frame->mpFrame, frame->mTS);
        }
    }
}

void RtmpPlayer::DropVideoFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::DropVideoFrame( "
//            "ts : %d "
//            ")",
//            frame->mTS
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnDropVideoFrame(this, frame->mpFrame, frame->mTS);
        }
    }
}

void RtmpPlayer::PlayAudioFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PlayAudioFrame( "
//            "ts : %d, "
//            ")",
//            frame->mTS
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnPlayAudioFrame(this, frame->mpFrame, frame->mTS);
        }
    }
}

void RtmpPlayer::DropAudioFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::DropAudioFrame( "
//            "ts : %d "
//            ")",
//            frame->mTS
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnDropAudioFrame(this, frame->mpFrame, frame->mTS);
        }
    }
}

}
