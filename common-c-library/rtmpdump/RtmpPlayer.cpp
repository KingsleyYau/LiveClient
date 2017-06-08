//
//  RtmpPlayer.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpPlayer.h"

// 默认视频数据播放缓存(毫秒)
#define PLAY_CACHE_DEFAULT_MS   300
#define PLAY_CACHE_MAX_MS  1500

// 最大视频数据缓存数量(帧个数)
#define PLAYVIDEO_CACHE_MAX_NUM     60

// 播放休眠
#define PLAY_SLEEP_TIME 1
// 帧延迟丢置值(MS)
#define PLAY_DELAY_DROP_TIME 50

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
	Init();
}

RtmpPlayer::RtmpPlayer(
                       VideoDecoder* pVideoDecoder,
                       AudioDecoder* pAudioDecoder,
                       RtmpPlayerCallback* callback
)
:mClientMutex(KMutex::MutexType_Recursive),
mPlayThreadMutex(KMutex::MutexType_Recursive)
{
	Init();

    mpVideoDecoder = pVideoDecoder;
    mpAudioDecoder = pAudioDecoder;
    mpRtmpPlayerCallback = callback;
}

RtmpPlayer::~RtmpPlayer() {
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
    
    FileLog("rtmpdump", "RtmpPlayer::PlayUrl( "
            "url : %s "
            ")",
            url.c_str()
            );

    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    bFlag = mRtmpDump.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
    if( bFlag ) {
        // 开始播放
        mbRunning = true;
        
        mPlayVideoThread.Start(mpPlayVideoRunnable);
        mPlayAudioThread.Start(mpPlayAudioRunnable);

    } else {
        Stop();
    }
    
    mClientMutex.unlock();
    
    return bFlag;
}

void RtmpPlayer::Stop() {
    mClientMutex.lock();
    
    FileLog("rtmpdump", "RtmpPlayer::Stop( "
    		"this : %p "
    		")",
			this
			);

    if( mbRunning ) {
        mbRunning = false;
        
        // 停止接收
        mRtmpDump.Stop();
        
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
        mCacheTotalMS = 0;

        mIsWaitCache = true;
        mResetVideoPlayTime = true;
        mResetAudioPlayTime = true;

        mStartPlayTime = 0;
        mPlayVideoAfterAudioDiff = 0;
    }
    
    mClientMutex.unlock();

    FileLog("rtmpdump", "RtmpPlayer::Stop( "
    		"[Success], "
    		"this : %p "
    		")",
			this
			);
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

void RtmpPlayer::SetVideoDecoder(VideoDecoder* decoder) {
    mpVideoDecoder = decoder;
}

void RtmpPlayer::SetAudioDecoder(AudioDecoder* decoder) {
    mpAudioDecoder = decoder;
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
    
    if( bCacheFrame ) {
        // 放到播放线程
        mVideoBufferList.lock();
        
        FrameBuffer* frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
        if( !frameBuffer ) {
            frameBuffer = new FrameBuffer();
        }
        
        if( frameBuffer ) {
            frameBuffer->mpFrame = (void *)frame;
            frameBuffer->mTimestamp = timestamp;
        }
        
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
    
    if( bCacheFrame ) {
        // 放到播放线程
        mAudioBufferList.lock();
        
        FrameBuffer* frameBuffer = (FrameBuffer *)mCacheBufferQueue.PopBuffer();
        if( !frameBuffer ) {
            frameBuffer = new FrameBuffer();
        }
        
        if( frameBuffer ) {
            frameBuffer->mpFrame = (void *)frame;
            frameBuffer->mTimestamp = timestamp;
        }
        
        mAudioBufferList.push_back(frameBuffer);
        mAudioBufferList.unlock();

    } else {
        // 直接播放
        FrameBuffer frameBuffer((void *)frame, timestamp);
        PlayAudioFrame(&frameBuffer);
    }
}

VideoDecoder* RtmpPlayer::GetVideoDecoder() {
	return mpVideoDecoder;
}

AudioDecoder* RtmpPlayer::GetAudioDecoder() {
	return mpAudioDecoder;
}

RtmpPlayerCallback* RtmpPlayer::GetCallback() {
	return mpRtmpPlayerCallback;
}

void RtmpPlayer::Init() {
    mbRunning = false;

    mCacheMS = PLAY_CACHE_DEFAULT_MS;
    mCacheTotalMS = 0;
    bCacheFrame = true;

    mStartPlayTime = 0;
    mPlayVideoAfterAudioDiff = 0;

    mIsWaitCache = true;
    mResetVideoPlayTime = true;
    mResetAudioPlayTime = true;

    mpVideoDecoder = NULL;
    mpAudioDecoder = NULL;
    mpRtmpPlayerCallback = NULL;

    mRtmpDump.SetCallback(this);
    mCacheBufferQueue.SetCacheQueueSize(100);

    mpPlayVideoRunnable = new PlayVideoRunnable(this);
    mpPlayAudioRunnable = new PlayAudioRunnable(this);
}

bool RtmpPlayer::IsCacheEnough() {
	bool bFlag = false;

	unsigned int startVideoTimestamp = 0;
	unsigned int endVideoTimestamp = 0;

	unsigned int startAudioTimestamp = 0;
	unsigned int endAudioTimestamp = 0;

	unsigned int startTimestamp = 0;
	unsigned int endTimestamp = 0;

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
	if( (endTimestamp - startTimestamp >= mCacheMS ) &&
			mVideoBufferList.size() > 0 &&
			mAudioBufferList.size() > 0
			) {
		// 缓存足够, 判断音频先开始还是视频先开始
		mPlayVideoAfterAudioDiff = startVideoTimestamp - startAudioTimestamp;
		if( mPlayVideoAfterAudioDiff >= 0 ) {
			// 音频先播
		} else {
			// 视频先播
		}

		FileLog("rtmpdump",
				"RtmpPlayer::IsCacheEnough( "
				"startVideoTimestamp : %u, "
				"endVideoTimestamp : %u, "
				"startAudioTimestamp : %u, "
				"endAudioTimestamp : %u, "
				"startTimestamp : %u, "
				"endTimestamp : %u, "
				"mPlayVideoAfterAudioDiff : %d, "
				"mVideoBufferList.size() : %d, "
				"mAudioBufferList.size() : %d "
				")",
				startVideoTimestamp,
				endVideoTimestamp,
				startAudioTimestamp,
				endAudioTimestamp,
				startTimestamp,
				endTimestamp,
				mPlayVideoAfterAudioDiff,
				mVideoBufferList.size(),
				mAudioBufferList.size()
				);

		bFlag = true;
	}
	mPlayThreadMutex.unlock();

	return bFlag;
}

bool RtmpPlayer::IsPlay(bool isAudio) {
	bool bFlag = false;

	long long curTime = (long long)getCurrentTime();

	mPlayThreadMutex.lock();
	int diffStartTime = -1;
	if( isAudio ) {
		if( mPlayVideoAfterAudioDiff < 0 ) {
			// 播放音频帧时候发现, 视频先播, 计算延迟
			diffStartTime = (int)(curTime - mStartPlayTime);
		}

		if( diffStartTime == -1 || diffStartTime >= abs(mPlayVideoAfterAudioDiff) ) {
//			FileLog("rtmpdump",
//					"RtmpPlayer::IsPlay( "
//					"[%s frame], "
//					"diffStartTime : %d, "
//					"mPlayVideoAfterAudioDiff : %d "
//					")",
//					isAudio?"Audio":"Video",
//					diffStartTime,
//					mPlayVideoAfterAudioDiff
//					);
			bFlag = true;
		}

	} else {
		if( mPlayVideoAfterAudioDiff >= 0 ) {
			// 播放视频帧时候发现, 音频先播, 计算延迟
			diffStartTime = (int)(curTime - mStartPlayTime);
		}

		if( diffStartTime == -1 || diffStartTime >= abs(mPlayVideoAfterAudioDiff) ) {
//			FileLog("rtmpdump",
//					"RtmpPlayer::IsPlay( "
//					"[%s frame], "
//					"diffStartTime : %d, "
//					"mPlayVideoAfterAudioDiff : %d "
//					")",
//					isAudio?"Audio":"Video",
//					diffStartTime,
//					mPlayVideoAfterAudioDiff
//					);
			bFlag = true;
		}
	}
	mPlayThreadMutex.unlock();

	return bFlag;
}

void RtmpPlayer::NoCacheFrame() {
	// 已经没有缓存数据，等待缓存
	mVideoBufferList.lock();
	mAudioBufferList.lock();

	mPlayThreadMutex.lock();
	if( mVideoBufferList.size() == 0 && mAudioBufferList.size() == 0 ) {
		mIsWaitCache = true;

		// 增加缓存时间
		mCacheMS = mCacheMS + PLAY_CACHE_DEFAULT_MS;
		if (mCacheMS > PLAY_CACHE_MAX_MS) {
			mCacheMS = PLAY_CACHE_MAX_MS;
		}

		FileLog("rtmpdump",
				"RtmpPlayer::NoCacheFrame( "
				"[Add Cache Time], "
				"mCacheMS : %u "
				")",
				mCacheMS
				);
	}
	mPlayThreadMutex.unlock();

	mAudioBufferList.unlock();
	mVideoBufferList.unlock();
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

    // 是否需要休眠
    bool bSleep = true;

    while( mbRunning ) {
    	bSleep = true;

    	// 判断是否有足够缓存
    	mPlayThreadMutex.lock();
    	if( mIsWaitCache ) {
    		if( IsCacheEnough() ) {
    			// 音频或者视频缓存成功, 马上开始播放
    			mIsWaitCache = false;

    			mResetAudioPlayTime = true;
    			mResetVideoPlayTime = true;

    			// 开播时间
    			mStartPlayTime = getCurrentTime();

    			FileLog("rtmpdump",
    					"RtmpPlayer::PlayFrame( "
    					"[Cache %s enough], "
    					"mCacheMS : %u, "
    					"mStartPlayTime : %lld "
    					")",
						isAudio?"Audio":"Video",
    					mCacheMS,
						mStartPlayTime
    					);
    		}
    		mPlayThreadMutex.unlock();

    	} else {
    		mPlayThreadMutex.unlock();

    		// 不用等待缓存
    		bufferList->lock();
    		if( !bufferList->empty() ) {
    			frame = bufferList->front();

    			// 是否开始播放
    			if( IsPlay(isAudio) ) {
    				// 当前时间
    				long long curTime = (long long)getCurrentTime();

    				mPlayThreadMutex.lock();
    				bool* bResetPlayTime = isAudio?&mResetAudioPlayTime:&mResetVideoPlayTime;
    				if( *bResetPlayTime ) {
    					// 重置开始播放时间
    					startTime = curTime;
    					preTime = startTime;

    					// 重置开始帧时间
    					startTimestamp = frame->mTimestamp;

    					*bResetPlayTime = false;

    					FileLog("rtmpdump",
    							"RtmpPlayer::PlayFrame( "
    							"[Restart %s Start Time], "
    							"startTime : %lld, "
    							"startTimestamp : %u "
    							")",
    							isAudio?"Audio":"Video",
    							startTime,
								startTimestamp
    							);
    				}
    				mPlayThreadMutex.unlock();

    				/**
    				 * 需要同步播放时间
    				 * 1.本地timestamp比服务器要大
    				 * 2.本地重置
    				 */
    				if( (preTimestamp > frame->mTimestamp) || (preTimestamp == 0) ) {
    					// 重置开始播放时间
    					startTime = curTime;
    					preTime = startTime;

    					// 重置开始帧时间
    					startTimestamp = frame->mTimestamp;
    					// 重置上次帧时间
    					preTimestamp = startTimestamp;

    					FileLog("rtmpdump",
    							"RtmpPlayer::PlayFrame( "
    							"[Reset %s Start Time], "
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
    				int diffTotalTime = (unsigned int)(curTime - startTime);
    				// 总帧时间差
    				int diffTotalms = frame->mTimestamp - startTimestamp;
    				// 是否丢帧
    				bool bDropFrame = false;
    				// 帧时间差, 去掉延迟值
    				int diffmsWithDelay = diffms;

    				// 帧延迟(总播放时间 > 总帧时间差)
    				int delay = diffTotalTime - diffTotalms;
    				if( diffms > 0 ) {
    					if( delay > 0 && (diffms > 0) ) {
    						// 播放延迟, 或者通知服务器降低发送帧率(允许每帧处理播放时间变长)，或者降低分辨率(减少每帧处理数据)
    						diffmsWithDelay = diffms - delay;

    						if( delay > diffms ) {
    							// 播放延迟总延迟大于允许值, 丢弃
    							bDropFrame = true;
    						} else if( diffmsWithDelay < 0 ) {
    							bDropFrame = true;
    						}

    					} else if( delay < 0 ){
    						// 帧延迟
    						if( delay < -diffms ) {
    							// 帧延迟总延迟大于缓存值允许值, 丢弃
    							bDropFrame = true;
    						}
    					}
    				}

//    				FileLog("rtmpdump",
//    						"RtmpPlayer::PlayFrame( "
//    						"[Get %s Frame], "
//    						"diffTime : %d, "
//    						"diffms : %d, "
//    						"delay : %d, "
//    						"bufferList->size() : %d "
//    						")",
//    						isAudio?"Audio":"Video",
//    						diffTime,
//    						diffms,
//    						delay,
//    						bufferList->size()
//    						);

    				bool bHandleFrame = false;
    				if( !bDropFrame ) {
    					/**
    					 * 判断是否到时间播放
    					 * 1.第一帧	(diffms == 0)
    					 * 2.(当前时间-上次播放时间 > ((帧时间戳 - 上帧时间戳) + 延迟))
    					 */
    					if( (diffms == 0) || (diffTime >= diffmsWithDelay) ) {
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
    					// 由于播放操作导致的时间差
    					int frameDelay = 0;
    					// 播放完成时间
    					long long playFinishTime = (long long)getCurrentTime();
    					// 计算播放用时
    					int playTime = (int)(playFinishTime - curTime);

    					// 丢弃帧不处理, 播放帧才处理
    					if( !bDropFrame ) {
//							FileLog("rtmpdump",
//									"RtmpPlayer::PlayFrame( "
//									"[Play %s Frame], "
//									"playTime : %d, "
//									"diffTime : %d, "
//									"diffms : %d, "
//									"delay : %d, "
//									"bufferList->size() : %d "
//									")",
//									isAudio?"Audio":"Video",
//									playTime,
//									diffTime,
//									diffms,
//									delay,
//									bufferList->size()
//									);

    						// 比较播放用时和帧时长
    						if( diffms > 0 && playTime >= diffms ) {
    							// 播放用时大于帧时长, 发生延迟
    							frameDelay = playTime - diffms;

    							// 不需要休眠，直接处理下一帧数据
    							bSleep = false;

    							FileLog("rtmpdump",
    									"RtmpPlayer::PlayFrame( "
    									"[Play %s Frame Delay], "
    									"playTime : %d, "
    									"diffTime : %d, "
    									"diffms : %d, "
    									"delay : %d, "
    									"frameDelay : %d "
    									"bufferList->size() : %d "
    									")",
    									isAudio?"Audio":"Video",
    									playTime,
    									diffTime,
    									diffms,
										delay,
    									frameDelay,
    									bufferList->size()
    									);
    						}
    					} else {
    						// 不需要休眠，直接处理下一帧数据
//    						bSleep = false;

    						FileLog("rtmpdump",
    								"RtmpPlayer::PlayFrame( "
    								"[Drop %s Frame], "
    								"diffTime : %d, "
    								"diffms : %d, "
    								"delay : %d, "
    								"bufferList->size() : %d "
    								")",
    								isAudio?"Audio":"Video",
    								diffTime,
    								diffms,
    								delay,
    								bufferList->size()
    								);
    					}

    					// 更新最后一帧播放开始时间
    					preTime = curTime;// - frameDelay;
    					preTimestamp = frame->mTimestamp;

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
    				}
    			} else {
    				// Not time to play
    			}

    		} else {
    			// 已经没有缓存数据，等待缓存
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

void RtmpPlayer::OnDisconnect(RtmpDump* rtmpDump) {
    if( mpRtmpPlayerCallback ) {
        mpRtmpPlayerCallback->OnDisconnect(this);
    }
}

void RtmpPlayer::OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLog("rtmpdump",
            "RtmpPlayer::OnChangeVideoSpsPps( "
            "sps_size : %d, "
            "pps_size : %d, "
            "nalUnitHeaderLength : %d "
            ")",
			sps_size,
			pps_size,
			nalUnitHeaderLength
            );
	if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoKeyFrame(sps, sps_size, pps, pps_size, nalUnitHeaderLength);
    }
}

void RtmpPlayer::OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::OnRecvVideoFrame( "
//            "timestamp : %d "
//            ")",
//			timestamp
//            );

	// 解码一帧
    if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoFrame(data, size, timestamp, video_type);
    }
}

void RtmpPlayer::OnChangeAudioFormat(RtmpDump* rtmpDump,
                                     AudioFrameFormat format,
                                     AudioFrameSoundRate sound_rate,
                                     AudioFrameSoundSize sound_size,
                                     AudioFrameSoundType sound_type
                                     ) {
    if( mpAudioDecoder ) {
        mpAudioDecoder->CreateAudioDecoder(format, sound_rate, sound_size, sound_type);
    }
}

void RtmpPlayer::OnRecvAudioFrame(
                                  RtmpDump* rtmpDump,
                                  AudioFrameFormat format,
                                  AudioFrameSoundRate sound_rate,
                                  AudioFrameSoundSize sound_size,
                                  AudioFrameSoundType sound_type,
                                  char* data,
                                  int size,
                                  u_int32_t timestamp
                                  ) {
//    FileLog("rtmpdump",
//            "RtmpPlayer::OnRecvAudioFrame( "
//            "timestamp : %d "
//            ")",
//			timestamp
//            );

    // 解码一帧
    if( mpAudioDecoder ) {
        mpAudioDecoder->DecodeAudioFrame(format, sound_rate, sound_size, sound_type, data, size, timestamp);
    }
}
