//
//  PlayerController.hpp
//  RtmpClient
//
//  Created by Max on 2017/6/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef PlayerController_h
#define PlayerController_h

#include <rtmpdump/RtmpDump.h>
#include <rtmpdump/RtmpPlayer.h>

#include <rtmpdump/IVideoRenderer.h>
#include <rtmpdump/IAudioRenderer.h>

#include <rtmpdump/video/VideoRecorderH264.h>
#include <rtmpdump/audio/AudioRecorderAAC.h>

#include <rtmpdump/Statistics.h>

#include <stdio.h>

#include <string>
using namespace std;

namespace coollive {
class PlayerController;
class PlayerStatusCallback {
public:
    virtual ~PlayerStatusCallback() {};
    virtual void OnPlayerConnect(PlayerController* pc) = 0;
    virtual void OnPlayerDisconnect(PlayerController* pc) = 0;
    virtual void OnPlayerOnDelayMaxTime(PlayerController* pc) = 0;
};
    
class PlayerController : public RtmpDumpCallback, VideoDecoderCallback, AudioDecoderCallback, RtmpPlayerCallback {
        
public:
    PlayerController();
    ~PlayerController();
    
    /**
     设置缓存时间

     @param cacheMS 缓存时间
     */
    void SetCacheMS(int cacheMS);
    /**
     设置视频渲染器

     @param videoRenderer 视频渲染器
     */
    void SetVideoRenderer(VideoRenderer* videoRenderer);
    /**
     设置音频渲染器
     
     @param audioRenderer 音频渲染器
     */
    void SetAudioRenderer(AudioRenderer* audioRenderer);
    
    /**
     设置视频解码器

     @param videoDecoder 视频解码器
     */
    void SetVideoDecoder(VideoDecoder* videoDecoder);
    /**
     设置音频解码器

     @param audioDecoder 音频解码器
     */
    void SetAudioDecoder(AudioDecoder* audioDecoder);
    
    /**
     设置状态回调

     @param pc 状态回调
     */
    void SetStatusCallback(PlayerStatusCallback* pc);
    
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
        
private:
    // 传输器回调
    void OnConnect(RtmpDump* rtmpDump);
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
        
    // 解码器回调
    void OnDecodeVideoFrame(VideoDecoder* decoder, void* frame, u_int32_t timestamp);
    void OnDecodeAudioFrame(AudioDecoder* decoder, void* frame, u_int32_t timestamp);
    
private:
    // 播放器回调
    void OnPlayVideoFrame(RtmpPlayer* player, void* frame);
    void OnDropVideoFrame(RtmpPlayer* player, void* frame);
    void OnPlayAudioFrame(RtmpPlayer* player, void* frame);
    void OnDropAudioFrame(RtmpPlayer* player, void* frame);
    void OnStartVideoStream(RtmpPlayer* player);
    void OnEndVideoStream(RtmpPlayer* player);
    void OnStartAudioStream(RtmpPlayer* player);
    void OnEndAudioStream(RtmpPlayer* player);
    void OnResetVideoStream(RtmpPlayer* player);
    void OnResetAudioStream(RtmpPlayer* player);
    void OnDelayMaxTime(RtmpPlayer* player);
    
private:
    // 传输器
    RtmpDump mRtmpDump;
    // 播放器
    RtmpPlayer mRtmpPlayer;
    // 解码器
    VideoDecoder* mpVideoDecoder;
    AudioDecoder* mpAudioDecoder;
    // 播放接口
    VideoRenderer* mpVideoRenderer;
    AudioRenderer* mpAudioRenderer;
    // 状态回调
    PlayerStatusCallback* mpPlayerStatusCallback;
    // 是否使用硬解码
    bool mUseHardDecoder;
    // 是否跳过延迟的帧
    bool mbSkipDelayFrame;
    // 录制模块
    VideoRecorderH264 mVideoRecorderH264;
    AudioRecorderAAC mAudioRecorderAAC;
    // 分析模块
    Statistics mStatistics;
    // 是否需要重置音频播放
    bool mbNeedResetAudioRenderer;
};
}

#endif /* PlayerController_h */
