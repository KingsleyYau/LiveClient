//
//  RtmpPlayer.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPlayer.h"

// 默认视频数据播放缓存(毫秒)
#define PLAY_CACHE_DEFAULT_MS   500
#define PLAY_CACHE_MAX_MS  1500

// 最大视频数据缓存数量(帧个数)
#define PLAYVIDEO_CACHE_MAX_NUM     60

// 播放休眠
#define PLAY_SLEEP_TIME 1
// 帧延迟丢置值(MS)
#define PLAY_DELAY_DROP_TIME 500

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
:mClientMutex(KMutex::MutexType_Recursive),
mPlayThreadMutex(KMutex::MutexType_Recursive)
{
    FileLog("rtmpdump", "RtmpPlayer::RtmpPlayer( player : %p )", this);
	Init();
}

RtmpPlayer::RtmpPlayer(
                       RtmpDump *rtmpDump,
                       RtmpPlayerCallback* callback
)
:mClientMutex(KMutex::MutexType_Recursive),
mPlayThreadMutex(KMutex::MutexType_Recursive)
{
    FileLog("rtmpdump", "RtmpPlayer::RtmpPlayer( player : %p )", this);
	Init();

    mpRtmpDump = rtmpDump;
    mpRtmpPlayerCallback = callback;
}

RtmpPlayer::~RtmpPlayer() {
    FileLog("rtmpdump", "RtmpPlayer::~RtmpPlayer( player : %p )", this);
    
    Stop();
    
    FrameBuffer* buffer = NULL;
    while( (buffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer()) ) {
        delete buffer;
    }
    
    if( mpPlayVideoRunnable ) {
        delete mpPlayVideoRunnable;
    }

    if( mpPlayAudioRunnable ) {
        delete mpPlayAudioRunnable;
    }
}

bool RtmpPlayer::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                "RtmpPlayer::PlayUrl( "
                "url : %s "
                ")",
                url.c_str()
                );

    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    bFlag = mpRtmpDump->PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
    if( bFlag ) {
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
            "[Finish], "
            "url : %s, "
            "bFlag : %s "
            ")",
            url.c_str(),
            bFlag?"true":"false"
            );
    
    return bFlag;
}

void RtmpPlayer::Stop() {
    mClientMutex.lock();
    
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "RtmpPlayer::Stop( "
                "this : %p "
                ")",
                this
                );

    if( mbRunning ) {
        mbRunning = false;
        
        // 停止接收
        mpRtmpDump->Stop();
        
        // 停止播放
        mPlayVideoThread.Stop();
        mPlayAudioThread.Stop();
        
        // 清除缓存
        FrameBuffer* frame = NULL;
        
//        FileLog("rtmpdump", "RtmpPlayer::Stop( "
//        		"[Clean Video Buffer], "
//        		"this : %p "
//        		")",
//    			this
//    			);

        // 清除视频缓存帧
        mVideoBufferList.lock();
        while( !mVideoBufferList.empty() ) {
            frame = mVideoBufferList.front();
            
            if( frame != NULL ) {
                if( mpRtmpPlayerCallback ) {
                    mpRtmpPlayerCallback->OnDropVideoFrame(this, frame->mpFrame);
                }
                
                // 回收资源
                if( !mCacheBufferQueue.PushBuffer(frame) ) {
                    // 归还失败，释放Buffer
                    delete frame;
                }
                
                mVideoBufferList.pop_front();
                
            } else {
                break;
            }
        }
        mVideoBufferList.unlock();
        
//        FileLog("rtmpdump", "RtmpPlayer::Stop( "
//        		"[Clean Audio Buffer], "
//        		"this : %p "
//        		")",
//    			this
//    			);

        // 清除音视频缓存帧
        mAudioBufferList.lock();
        while( !mAudioBufferList.empty() ) {
            frame = mAudioBufferList.front();
            
            if( frame != NULL ) {
                if( mpRtmpPlayerCallback ) {
                    mpRtmpPlayerCallback->OnDropAudioFrame(this, frame->mpFrame);
                }
                
                // 回收资源
                if( !mCacheBufferQueue.PushBuffer(frame) ) {
                    // 归还失败，释放Buffer
                    delete frame;
                }
                
                mAudioBufferList.pop_front();
                
            } else {
                break;
            }
        }
        mAudioBufferList.unlock();
        
//        FileLog("rtmpdump", "RtmpPlayer::Stop( "
//        		"[Clean Cache Buffer], "
//        		"this : %p "
//        		")",
//    			this
//    			);

        // 清除内存池Buffer
        while( (frame = (FrameBuffer *)mCacheBufferQueue.PopBuffer()) != NULL ) {
            delete frame;
        }
        
        // 还原参数
        mCacheMS = PLAY_CACHE_DEFAULT_MS;
        
        mIsWaitCache = true;

        mStartPlayTime = 0;
        mPlayVideoAfterAudioDiff = 0;
    }
    
    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "RtmpPlayer::Stop( "
                "[Success], "
                "this : %p "
                ")",
                this
                );
}

void RtmpPlayer::SetRtmpDump(RtmpDump* rtmpDump) {
    mpRtmpDump = rtmpDump;
}
    
void RtmpPlayer::SetCallback(RtmpPlayerCallback* callback) {
    mpRtmpPlayerCallback = callback;
}

void RtmpPlayer::PlayVideoRunnableHandle() {
	PlayFrame(false);
}

void RtmpPlayer::PlayAudioRunnableHandle() {
	PlayFrame(true);
}

void RtmpPlayer::PushVideoFrame(void* frame, u_int32_t timestamp) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PushVideoFrame( "
//            "frame : %p, "
//            "timestamp : %u "
//            ")",
//            frame,
//            timestamp
//            );
    mPlayThreadMutex.lock();
    mbShowNoCacheLog = false;
    mPlayThreadMutex.unlock();
    
    if( mbCacheFrame ) {
        // 放到播放线程
        
        FrameBuffer* frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
        if( !frameBuffer ) {
            frameBuffer = new FrameBuffer();
        }
        
        if( frameBuffer ) {
            frameBuffer->mpFrame = (void *)frame;
            frameBuffer->mTimestamp = timestamp;
        }
        
        mVideoBufferList.lock();
        mVideoBufferList.push_back(frameBuffer);
        mVideoBufferList.unlock();
        
    } else {
        // 直接播放
        FrameBuffer frameBuffer((void *)frame, timestamp);
        PlayVideoFrame(&frameBuffer);
    }
}

void RtmpPlayer::PushAudioFrame(void* frame, u_int32_t timestamp) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PushAudioFrame( "
//            "frame : %p, "
//            "timestamp : %u "
//            ")",
//            frame,
//            timestamp
//            );
    
    mPlayThreadMutex.lock();
    mbShowNoCacheLog = false;
    mPlayThreadMutex.unlock();
    
    if( mbCacheFrame ) {
        // 放到播放线程
        
        FrameBuffer* frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
        if( !frameBuffer ) {
            frameBuffer = new FrameBuffer();
            //            FileLog("rtmpdump",
            //                    "RtmpPlayer::PushAudioFrame( "
            //                    "[New Frame Buffer], "
            //                    "frame : %p, "
            //                    "timestamp : %u "
            //                    ")",
            //                    frame,
            //                    timestamp
            //                    );
            
        }
        
        if( frameBuffer ) {
            frameBuffer->mpFrame = (void *)frame;
            frameBuffer->mTimestamp = timestamp;
        }
        
        mAudioBufferList.lock();
        mAudioBufferList.push_back(frameBuffer);
        mAudioBufferList.unlock();

    } else {
        // 直接播放
        FrameBuffer frameBuffer((void *)frame, timestamp);
        PlayAudioFrame(&frameBuffer);
    }
}

RtmpPlayerCallback* RtmpPlayer::GetCallback() {
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
    mPlayVideoAfterAudioDiff = 0;

    mIsWaitCache = true;

    mpRtmpDump = NULL;
    mpRtmpPlayerCallback = NULL;

    mCacheBufferQueue.SetCacheQueueSize(100);

    mpPlayVideoRunnable = new PlayVideoRunnable(this);
    mpPlayAudioRunnable = new PlayAudioRunnable(this);
    
    mbShowNoCacheLog = false;
}

bool RtmpPlayer::IsCacheEnough() {
	bool bFlag = false;

	int startVideoTimestamp = 0;
	int endVideoTimestamp = 0;

	int startAudioTimestamp = 0;
	int endAudioTimestamp = 0;

	int startTimestamp = 0;
	int endTimestamp = 0;

	FrameBuffer* videoFrame = NULL;
	FrameBuffer* audioFrame = NULL;

	mVideoBufferList.lock();
	if( !mVideoBufferList.empty() ) {
		videoFrame = mVideoBufferList.front();
		startVideoTimestamp = videoFrame->mTimestamp;
		if( (startTimestamp == 0) || startTimestamp > startVideoTimestamp ) {
			startTimestamp = videoFrame->mTimestamp;
		}

		videoFrame = mVideoBufferList.back();
		endVideoTimestamp = videoFrame->mTimestamp;
		if( endTimestamp < endVideoTimestamp ) {
			endTimestamp = videoFrame->mTimestamp;
		}
	}
	mVideoBufferList.unlock();

	mAudioBufferList.lock();
	if( !mAudioBufferList.empty() ) {
		audioFrame = mAudioBufferList.front();
		startAudioTimestamp = audioFrame->mTimestamp;
		if( (startTimestamp == 0) || startTimestamp > startAudioTimestamp ) {
			startTimestamp = audioFrame->mTimestamp;
		}

		audioFrame = mAudioBufferList.back();
		endAudioTimestamp = audioFrame->mTimestamp;
		if( endTimestamp < endAudioTimestamp ) {
			endTimestamp = audioFrame->mTimestamp;
		}
	}
	mAudioBufferList.unlock();

	mPlayThreadMutex.lock();
	if( endTimestamp - startTimestamp >= mCacheMS ) {
		// 缓存足够, 判断音频先开始还是视频先开始
        if( startVideoTimestamp > 0 && startAudioTimestamp > 0 ) {
            mPlayVideoAfterAudioDiff = startVideoTimestamp - startAudioTimestamp;
            if( mPlayVideoAfterAudioDiff >= 0 ) {
                // 音频先播
            } else {
                // 视频先播
            }
        }

//		FileLog("rtmpdump",
//				"RtmpPlayer::IsCacheEnough( "
//				"startVideoTimestamp : %d, "
//				"endVideoTimestamp : %d, "
//				"startAudioTimestamp : %d, "
//				"endAudioTimestamp : %d, "
//				"startTimestamp : %d, "
//				"endTimestamp : %d, "
//				"mPlayVideoAfterAudioDiff : %d, "
//				"mVideoBufferList.size() : %d, "
//				"mAudioBufferList.size() : %d "
//				")",
//				startVideoTimestamp,
//				endVideoTimestamp,
//				startAudioTimestamp,
//				endAudioTimestamp,
//				startTimestamp,
//				endTimestamp,
//				mPlayVideoAfterAudioDiff,
//				mVideoBufferList.size(),
//				mAudioBufferList.size()
//				);

		bFlag = true;
	}
	mPlayThreadMutex.unlock();

	return bFlag;
}

bool RtmpPlayer::IsRestStream(FrameBuffer* frame, unsigned int preTimestamp) {
    bool bFlag = false;
    
    if( frame ) {
        /**
         * 需要同步播放时间
         * 1.本地timestamp比服务器要大
         */
        if( preTimestamp > frame->mTimestamp ) {
            bFlag = true;
    //        // 重置开始播放时间
    //        startTime = curTime;
    //        preTime = startTime;
    //
    //        // 重置开始帧时间
    //        startTimestamp = frame->mTimestamp;
    //        // 重置上次帧时间
    //        preTimestamp = startTimestamp;
    //
    //        FileLog("rtmpdump",
    //                "RtmpPlayer::PlayFrame( "
    //                "[Reset %s Start Time], "
    //                "startTime : %lld, "
    //                "startTimestamp : %u, "
    //                "bufferList->size() : %u "
    //                ")",
    //                isAudio?"Audio":"Video",
    //                startTime,
    //                startTimestamp,
    //                bufferList->size()
    //                );
            
        }
    }

    return bFlag;
}
    
bool RtmpPlayer::IsPlay(bool isAudio) {
	bool bFlag = false;

	long long curTime = (long long)getCurrentTime();

    if( mbSyncFrame ) {
        mPlayThreadMutex.lock();
        int diffStartTime = -1;
        if( isAudio ) {
            if( mPlayVideoAfterAudioDiff < 0 ) {
                // 播放音频帧时候发现, 视频先播, 计算延迟
                diffStartTime = (int)(curTime - mStartPlayTime);
            }
            
            if( diffStartTime == -1 || diffStartTime >= abs(mPlayVideoAfterAudioDiff) ) {
                bFlag = true;
            }
            
        } else {
            if( mPlayVideoAfterAudioDiff >= 0 ) {
                // 播放视频帧时候发现, 音频先播, 计算延迟
                diffStartTime = (int)(curTime - mStartPlayTime);
            }
            
            if( diffStartTime == -1 || diffStartTime >= abs(mPlayVideoAfterAudioDiff) ) {
                bFlag = true;
            }
        }
        mPlayThreadMutex.unlock();
    } else {
        bFlag = true;
    }

	return bFlag;
}

void RtmpPlayer::NoCacheFrame() {
	// 已经没有缓存数据，等待缓存
	mPlayThreadMutex.lock();
	if( mVideoBufferList.size() == 0 && mAudioBufferList.size() == 0 ) {
        
        if( !mbShowNoCacheLog ) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "RtmpPlayer::NoCacheFrame( "
                         "mCacheMS : %u "
                         ")",
                         mCacheMS
                         );
            mbShowNoCacheLog = true;
        }

	}
	mPlayThreadMutex.unlock();
}

void RtmpPlayer::PlayFrame(bool isAudio) {
    // 帧缓存
    FrameBuffer* frame = NULL;
    FrameBufferList* bufferList = NULL;

    if( isAudio ) {
    	// 播放音频
    	bufferList = &mAudioBufferList;

    } else {
    	// 播放视频
    	bufferList = &mVideoBufferList;
    }

    // 开始播放时间
    long long startTime = 0;
    // 上一帧视频播放时间
    long long preTime = 0;
    // 开始播放帧时间戳
    unsigned int startTimestamp = 0;
    // 上一帧视频播放时间戳
    unsigned int preTimestamp = 0;

    // 由于播放操作导致的时间差
    int handleDelay = 0;
    
    bool bSleep = true;
    
    while( mbRunning ) {
        bSleep = true;
        
    	// 判断是否需要缓存
    	mPlayThreadMutex.lock();
    	if( mIsWaitCache ) {
    		if( IsCacheEnough() ) {
    			// 音频或者视频缓存成功, 马上开始播放
    			mIsWaitCache = false;

    			// 开播时间
    			mStartPlayTime = getCurrentTime();

    			FileLevelLog("rtmpdump",
                            KLog::LOG_WARNING,
                            "RtmpPlayer::PlayFrame( "
                            "[Cache %s enough], "
                            "mCacheMS : %u, "
                            "mStartPlayTime : %lld, "
                            "mPlayVideoAfterAudioDiff : %d, "
                            "bufferList size : %u "
                            ")",
                            isAudio?"Audio":"Video",
                            mCacheMS,
                            mStartPlayTime,
                            mPlayVideoAfterAudioDiff,
                            bufferList->size()
                            );

    		}

            mPlayThreadMutex.unlock();
            
    	} else {
            mPlayThreadMutex.unlock();
            
    		// 不用等待缓存
    		bufferList->lock();
    		if( !bufferList->empty() ) {
    			frame = bufferList->front();

                // 是否需要重置时间戳
                if( IsRestStream(frame, preTimestamp) ) {
                    // 重新开始缓存
                    mPlayThreadMutex.lock();
                    mIsWaitCache = true;
                    mPlayThreadMutex.unlock();
                    
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "RtmpPlayer::PlayFrame( "
                                 "[Reset %s Start Timestamp], "
                                 "startTime : %lld, "
                                 "frame->mTimestamp : %u, "
                                 "preTimestamp : %u, "
                                 "bufferList size : %u "
                                 ")",
                                 isAudio?"Audio":"Video",
                                 startTime,
                                 frame->mTimestamp,
                                 preTimestamp,
                                 bufferList->size()
                                 );
                    
                    // 重置上帧时间戳
                    preTimestamp = 0;
                    
                    if( mpRtmpPlayerCallback ) {
                        if( isAudio ) {
                            mpRtmpPlayerCallback->OnResetAudioStream(this);
                        } else {
                            mpRtmpPlayerCallback->OnResetVideoStream(this);
                        }
                    }
                    
                } else {
                    // 是否需要播放
                    if( IsPlay(isAudio) ) {
                        // 当前时间
                        long long curTime = (long long)getCurrentTime();
                        
                        if( preTimestamp == 0 ) {
                            // 重置开始播放时间
                            startTime = curTime;
                            preTime = startTime;
                            
                            // 重置开始帧时间
                            startTimestamp = frame->mTimestamp;
                            // 重置上次帧时间
                            preTimestamp = startTimestamp;
                            
                            FileLevelLog("rtmpdump",
                                        KLog::LOG_WARNING,
                                         "RtmpPlayer::PlayFrame( "
                                        "[Start Play %s], "
                                        "startTime : %lld, "
                                        "startTimestamp : %u, "
                                        "bufferList->size() : %u "
                                        ")",
                                        isAudio?"Audio":"Video",
                                        startTime,
                                        startTimestamp,
                                        bufferList->size()
                                        );
                        }
                        
                        // 本地两帧播放时间差
                        int diffTime = (int)(curTime - preTime);
                        // 两帧时间差
                        int diffms = frame->mTimestamp - preTimestamp;
                        // 总播放时间差
                        int diffTotalTime = (int)(curTime - startTime);
                        // 总帧时间差
                        int diffTotalms = frame->mTimestamp - startTimestamp;
                        // 是否丢帧
                        bool bDropFrame = false;
                        
                        // 帧延迟(总播放时间 - 总帧时间差)
                        int delay = diffTotalTime - diffTotalms;
                        
//                        if( !isAudio ) {
//                            // 只有视频才丢帧
                            if( diffms > 0 ) {
                                if( delay > 0 ) {
                                    // 播放延迟, 或者通知服务器降低发送帧率(允许每帧处理播放时间变长)，或者降低分辨率(减少每帧处理数据)
                                    if( delay > PLAY_DELAY_DROP_TIME ) {
                                        // 播放延迟总延迟大于允许值, 丢弃
                                        bDropFrame = true;
                                    }
                                    
                                }
                            }
//                        }
                        
//                        FileLog("rtmpdump",
//                                "RtmpPlayer::PlayFrame( "
//                                "[Get %s Frame], "
//                                "diffTime : %d, "
//                                "diffms : %d, "
//                                "delay : %d, "
//                                "frame->mTimestamp : %u, "
//                                "buffer size : %d "
//                                ")",
//                                isAudio?"Audio":"Video",
//                                diffTime,
//                                diffms,
//                                delay,
//                                frame->mTimestamp,
//                                bufferList->size()
//                                );
                        
                        bool bHandleFrame = false;
                        if( !bDropFrame ) {
                            // 播放帧
//                            if( isAudio ) {
//                                PlayAudioFrame(frame);
//                                bHandleFrame = true;
//                                
//                            } else {
//                                /**
//                                 * 判断是否到时间播放
//                                 * 1.第一帧(diffms == 0)
//                                 * 2.(总播放时间 - 总帧时间戳 > 帧时间戳差)
//                                 */
//                                if( (diffms == 0) || delay > diffms) {
//                                    PlayVideoFrame(frame);
//                                    bHandleFrame = true;
//                                }
//                            }

                            /**
                             * 判断是否到时间播放
                             * 1.第一帧(diffms == 0)
                             * 2.(总播放时间 - 总帧时间戳 > 帧时间戳差)
                             */
                            if( (diffms == 0) || ( diffTime >= (diffms - delay) )/*delay > (diffms - 2 * PLAY_SLEEP_TIME)*/ ) {
                                // 播放帧
                                if( isAudio ) {
                                    PlayAudioFrame(frame);
                                } else {
                                    PlayVideoFrame(frame);
                                }
                                
                                bHandleFrame = true;
                            }
                            
                        } else {
                            // 本地丢帧
                            if( isAudio ) {
                                DropAudioFrame(frame);
                            } else {
                                DropVideoFrame(frame);
                            }
                            
                            bHandleFrame = true;
                        }
                        
                        if( bHandleFrame ) {
                            // 播放完成时间
                            long long handleFinishTime = (long long)getCurrentTime();
                            // 计算播放用时
                            int handleTime = (int)(handleFinishTime - curTime);
                            
                            // 丢弃帧不处理, 播放帧才处理
                            if( !bDropFrame ) {
                                FileLevelLog("rtmpdump",
                                            KLog::LOG_MSG,
                                            "RtmpPlayer::PlayFrame( "
                                            "[Play %s Frame], "
                                            "handleTime : %d, "
                                            "diffTime : %d, "
                                            "diffms : %d, "
                                            "delay : %d, "
                                            "frame->mTimestamp : %u, "
                                            "diffTotalTime : %d, "
                                            "diffTotalms : %d, "
                                            "buffer size : %d "
                                            ")",
                                            isAudio?"Audio":"Video",
                                            handleTime,
                                            diffTime,
                                            diffms,
                                            delay,
                                            frame->mTimestamp,
                                            diffTotalTime,
                                            diffTotalms,
                                            bufferList->size()
                                            );
                            } else {
                                // 丢帧不需要休眠，直接处理下一帧数据
                                FileLevelLog("rtmpdump",
                                            KLog::LOG_MSG,
                                            "RtmpPlayer::PlayFrame( "
                                            "[Drop %s Frame], "
                                            "handleTime : %d, "
                                            "diffTime : %d, "
                                            "diffms : %d, "
                                            "delay : %d, "
                                            "frame->mTimestamp : %u, "
                                            "diffTotalTime : %d, "
                                            "diffTotalms : %d, "
                                            "bufferList size() : %d "
                                            ")",
                                            isAudio?"Audio":"Video",
                                            handleTime,
                                            diffTime,
                                            diffms,
                                            delay,
                                            frame->mTimestamp,
                                            diffTotalTime,
                                            diffTotalms,
                                            bufferList->size()
                                            );
                            }

                            // 比较处理用时和帧时长
                            if( diffms > 0 && handleTime >= diffms ) {
                                // 播放用时大于帧时长, 发生延迟
                                handleDelay = handleTime - diffms;
                                
//                                FileLog("rtmpdump",
//                                        "RtmpPlayer::PlayFrame( "
//                                        "[Handle %s Frame Delay], "
//                                        "handleTime : %d, "
//                                        "diffTime : %d, "
//                                        "diffms : %d, "
//                                        "delay : %d, "
//                                        "frameDelay : %d "
//                                        "bufferList size() : %d "
//                                        ")",
//                                        isAudio?"Audio":"Video",
//                                        handleTime,
//                                        diffTime,
//                                        diffms,
//                                        delay,
//                                        handleDelay,
//                                        bufferList->size()
//                                        );
                            }
                            
                            // 队列去除
                            bufferList->pop_front();
                            
                            // 回收资源
                            if( !mCacheBufferQueue.PushBuffer(frame) ) {
                                // 归还失败，释放Buffer
                                FileLog("rtmpdump",
                                        "RtmpPlayer::PlayFrame( "
                                        "[Delete %s frame], "
                                        "frame : %p "
                                        ")",
                                        isAudio?"Audio":"Video",
                                        frame
                                        );
                                delete frame;
                            }
                            
                            // 更新最后一帧播放开始时间
                            preTime = curTime;// - frameDelay;
                            preTimestamp = frame->mTimestamp;
                        }
                    }
                }
    		} else {
    			// 已经没有缓存数据
    			NoCacheFrame();
    		}
    		bufferList->unlock();
    	}

        if( bSleep ) {
            Sleep(PLAY_SLEEP_TIME);
        }
    }

}

void RtmpPlayer::PlayVideoFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PlayVideoFrame( "
//            "timestamp : %d "
//            ")",
//            frame->mTimestamp
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnPlayVideoFrame(this, frame->mpFrame);
        }
    }
}

void RtmpPlayer::DropVideoFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::DropVideoFrame( "
//            "timestamp : %d "
//            ")",
//            frame->mTimestamp
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnDropVideoFrame(this, frame->mpFrame);
        }
    }
}

void RtmpPlayer::PlayAudioFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::PlayAudioFrame( "
//            "timestamp : %d, "
//            ")",
//            frame->mTimestamp
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnPlayAudioFrame(this, frame->mpFrame);
        }
    }
}

void RtmpPlayer::DropAudioFrame(FrameBuffer* frame) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::DropAudioFrame( "
//            "timestamp : %d "
//            ")",
//            frame->mTimestamp
//            );
    if( frame != NULL ) {
        if( mpRtmpPlayerCallback ) {
            mpRtmpPlayerCallback->OnDropAudioFrame(this, frame->mpFrame);
        }
    }
}

}
