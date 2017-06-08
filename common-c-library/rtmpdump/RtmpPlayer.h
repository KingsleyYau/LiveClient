//
//  RtmpPlayer.h
//  RtmpClient
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef RtmpPlayer_hpp
#define RtmpPlayer_hpp

#include <stdio.h>

#include <common/CommonFunc.h>

#include <rtmpdump/RtmpDump.h>

#include "IDecoder.h"
#include "FrameBuffer.h"
#include "CacheBufferQueue.h"
#include "VideoDecoderH264.h"

// 音视频帧缓存队列
typedef list_lock<FrameBuffer *> FrameBufferList;

class RtmpPlayer;
class RtmpPlayerCallback {
public:
    virtual ~RtmpPlayerCallback(){};
    virtual void OnDisconnect(RtmpPlayer* player) = 0;
    virtual void OnPlayVideoFrame(RtmpPlayer* player, void* frame) = 0;
    virtual void OnDropVideoFrame(RtmpPlayer* player, void* frame) = 0;
    virtual void OnPlayAudioFrame(RtmpPlayer* player, void* frame) = 0;
    virtual void OnDropAudioFrame(RtmpPlayer* player, void* frame) = 0;
};

class PlayVideoRunnable;
class PlayAudioRunnable;
class RtmpPlayer : public RtmpDumpCallback {
public:
    RtmpPlayer();
    RtmpPlayer(
               VideoDecoder* pVideoDecoder,
               AudioDecoder* pAudioDecoder,
               RtmpPlayerCallback* callback
    );
    ~RtmpPlayer();
    
    /**
     播放流连接
     
     @param url 连接
     @param recordFilePath flv录制路径
     @param recordH264FilePath H264录制路径
     @return 成功／失败
     */
    bool PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath);
    
    /**
     停止
     */
    void Stop();

    /**
     播放一个视频帧

     @param frame 视频帧
     @param timestamp 时间戳
     */
    void PushVideoFrame(void* frame, u_int32_t timestamp);
    
    /**
     播放一个音频帧

     @param frame 音频帧
     @param timestamp 时间戳
     */
    void PushAudioFrame(void* frame, u_int32_t timestamp);
    
    /**
     获取视频编码器

     @return 视频编码器
     */
    VideoDecoder* GetVideoDecoder();
    
    /**
     获取音频编码器

     @return 音频编码器
     */
    AudioDecoder* GetAudioDecoder();
    
    /**
     获取回调

     @return 回调
     */
    RtmpPlayerCallback* GetCallback();

public:
    void SetCallback(RtmpPlayerCallback* callback);
    void SetVideoDecoder(VideoDecoder* decoder);
    void SetAudioDecoder(AudioDecoder* decoder);

public:
    void PlayVideoRunnableHandle();
    void PlayAudioRunnableHandle();

private:
    void OnDisconnect(RtmpDump* rtmpDump);
    void OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void OnChangeAudioFormat(RtmpDump* rtmpDump,
                             AudioFrameFormat format,
                             AudioFrameSoundRate sound_rate,
                             AudioFrameSoundSize sound_size,
                             AudioFrameSoundType sound_type
                             );
    void OnRecvAudioFrame(RtmpDump* rtmpDump,
                          AudioFrameFormat format,
                          AudioFrameSoundRate sound_rate,
                          AudioFrameSoundSize sound_size,
                          AudioFrameSoundType sound_type,
                          char* data,
                          int size,
                          u_int32_t timestamp
                          );
    
private:
    void Init();
    // 是否等待缓存
    bool IsCacheEnough();
    // 是否开始播放
    bool IsPlay(bool isAudio);
    // 没有需要播放的Buffer
    void NoCacheFrame();

    // 播放帧
    void PlayFrame(bool isAudio);
    void PlayAudio();

    // 播放一个视频帧
    void PlayVideoFrame(FrameBuffer* frame);
    void DropVideoFrame(FrameBuffer* frame);
    
    // 播放一个音频帧
    void PlayAudioFrame(FrameBuffer* frame);
    void DropAudioFrame(FrameBuffer* frame);
    
    // 播放回调
    RtmpPlayerCallback* mpRtmpPlayerCallback;
    
    // Rtmp传输模块
    RtmpDump mRtmpDump;
    
    // 播放线程
    KThread mPlayVideoThread;
    PlayVideoRunnable* mpPlayVideoRunnable;
    KThread mPlayAudioThread;
    PlayAudioRunnable* mpPlayAudioRunnable;
    
    // 解码器
    VideoDecoder* mpVideoDecoder;
    AudioDecoder* mpAudioDecoder;
    
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
    unsigned int mCacheTotalMS;

    // 是否开启缓存
    bool bCacheFrame;
    // 缓存锁
    KMutex mPlayThreadMutex;
    // 是否等待缓存
    bool mIsWaitCache;

    // 是否重置本地播放时间
    bool mResetAudioPlayTime;
    bool mResetVideoPlayTime;

    // 开始播放的时间
    long long mStartPlayTime;
    // 音视频开始播放时间差
    int mPlayVideoAfterAudioDiff;
};

#endif /* RtmpPlayer_h */
