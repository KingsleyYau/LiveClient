//
//  RtmpPlayer.h
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef RtmpPlayer_hpp
#define RtmpPlayer_hpp

#include <common/CommonFunc.h>

#include <rtmpdump/RtmpDump.h>
#include <rtmpdump/IDecoder.h>

#include <rtmpdump/util/FrameBuffer.h>
#include <rtmpdump/util/CacheBufferQueue.h>

#include <stdio.h>

namespace coollive {

class RtmpPlayer;
class RtmpPlayerCallback {
  public:
    virtual ~RtmpPlayerCallback(){};

    virtual void OnPlayVideoFrame(RtmpPlayer *player, void *frame) = 0;
    virtual void OnDropVideoFrame(RtmpPlayer *player, void *frame) = 0;
    virtual void OnPlayAudioFrame(RtmpPlayer *player, void *frame) = 0;
    virtual void OnDropAudioFrame(RtmpPlayer *player, void *frame) = 0;
    virtual void OnResetVideoStream(RtmpPlayer *player) = 0;
    virtual void OnResetAudioStream(RtmpPlayer *player) = 0;
    virtual void OnDelayMaxTime(RtmpPlayer *player) = 0;
    virtual void OnOverMaxBufferFrameCount(RtmpPlayer *player) = 0;
};

class PlayVideoRunnable;
class PlayAudioRunnable;
class RtmpPlayer {
  public:
    RtmpPlayer();
    RtmpPlayer(
        RtmpDump *rtmpDump,
        RtmpPlayerCallback *callback);
    ~RtmpPlayer();

    /**
     播放流连接
     
     @param recordFilePath flv录制路径
     @return 成功／失败
     */
    bool PlayUrl(const string &recordFilePath);

    /**
     停止
     */
    void Stop();

    /**
     播放一个视频帧

     @param frame 视频帧
     @param timestamp 时间戳
     */
    void PushVideoFrame(void *frame, u_int32_t timestamp);

    /**
     播放一个音频帧

     @param frame 音频帧
     @param timestamp 时间戳
     */
    void PushAudioFrame(void *frame, u_int32_t timestamp);

    /**
     获取回调

     @return 回调
     */
    RtmpPlayerCallback *GetCallback();

    /**
     设置是否允许延迟丢帧

     @param canDropFrame 是否允许延迟丢帧
     */
    void SetCanDropFrame(bool canDropFrame);

    /**
     获取缓存视频数量

     @return <#return value description#>
     */
    size_t GetVideBufferSize();

  public:
    void SetRtmpDump(RtmpDump *rtmpDump);
    void SetCallback(RtmpPlayerCallback *callback);
    void SetCacheMS(int cacheMS);
    int CahceMS() const;
    void SetCacheNoLimit(bool bNoCacheLimit);
    void SetPlaybackRate(float playBackRate);
    
  public:
    void PlayVideoRunnableHandle();
    void PlayAudioRunnableHandle();

  private:
    void Init();
    // 缓存时间是否足够
    bool IsCacheEnough();
    // 是否重置播放流
    bool IsRestStream(FrameBuffer *frame, unsigned int preTimestamp);
    // 是否开始播放
    bool IsPlay(bool isAudio);
    // 没有需要播放的Buffer
    void NoCacheFrame();

    // 播放帧
    void PlayFrame(bool isAudio);
    void PlayAudio();

    // 播放一个视频帧
    void PlayVideoFrame(FrameBuffer *frame);
    void DropVideoFrame(FrameBuffer *frame);

    // 播放一个音频帧
    void PlayAudioFrame(FrameBuffer *frame);
    void DropAudioFrame(FrameBuffer *frame);

    // 播放回调
    RtmpPlayerCallback *mpRtmpPlayerCallback;

    // Rtmp传输模块
    RtmpDump *mpRtmpDump;

    // 播放线程
    KThread mPlayVideoThread;
    PlayVideoRunnable *mpPlayVideoRunnable;
    KThread mPlayAudioThread;
    PlayAudioRunnable *mpPlayAudioRunnable;

    // 状态锁
    KMutex mClientMutex;
    bool mbRunning;

    // 缓存Buffer列表
    FrameBufferList mVideoBufferList;
    FrameBufferList mAudioBufferList;
    // 空闲的Buffer列表
    CacheBufferQueue mCacheBufferQueue;

    // 播放的缓存时间(毫秒)
    unsigned int mCacheMS;

    // 是否开启缓存
    bool mbCacheFrame;
    // 是否开启音视频同步
    bool mbSyncFrame;
    // 缓存锁
    KMutex mPlayThreadMutex;
    // 是否等待缓存
    bool mIsWaitCache;

    // 开始播放的时间, 用于音视频同步
    long long mStartPlayTime;
    // 视频开播时间戳
    bool mbVideoStartPlay;
    // 音频开播时间戳
    bool mbAudioStartPlay;
    // 当前缓存的视频时间戳
    int mVideoFrontTimestamp;
    int mVideoBackTimestamp;
    // 当前缓存的音频时间戳
    int mAudioFrontTimestamp;
    int mAudioBackTimestamp;
    
    // 是否第一次不够缓存
    bool mbShowNoCacheLog;
    
    // 是否不限制内存
    bool mbNoCacheLimit;
    
    // 播放速度
    float mPlaybackRate;
    bool mPlaybackRateChange;
};
}
#endif /* RtmpPlayer_h */
