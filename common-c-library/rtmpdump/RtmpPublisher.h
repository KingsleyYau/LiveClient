//
//  RtmpPublisher.h
//  RtmpClient
//
//  Created by Max on 2017/4/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef RtmpPublisher_h
#define RtmpPublisher_h

#include <stdio.h>

#include <common/CommonFunc.h>

#include <rtmpdump/RtmpDump.h>

#include "IDecoder.h"

class VideoEncoder;
class AudioEncoder;
class RtmpPublisher;
class RtmpPublisherCallback {
public:
    virtual ~RtmpPublisherCallback(){};
    virtual void OnDisconnect(RtmpPublisher* publisher) = 0;
};

class RtmpPublisher : public RtmpDumpCallback {
public:
	RtmpPublisher();
    ~RtmpPublisher();
    
    /**
     发布流连接
     
     @param url 连接
     @param recordH264FilePath H264录制路径
     @param recordAACFilePath AAC录制路径
     @return 成功／失败
     */
    bool PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath);
    
    /**
     停止
     */
    void Stop();

    /**
     发送原始h264视频帧
     
     @param frame <#frame description#>
     @param frame_size <#frame_size description#>
     @return <#return value description#>
     */
    bool SendVideoFrame(char* frame, int frame_size);
    void AddVideoTimestamp(u_int32_t timestamp);
  
    /**
     发送原始音频帧
     
     @param sound_format <#sound_format description#>
     @param sound_rate <#sound_rate description#>
     @param sound_size <#sound_size description#>
     @param sound_type <#sound_type description#>
     @param frame <#frame description#>
     @param frame_size <#frame_size description#>
     @return <#return value description#>
     */
    bool SendAudioFrame(AudioFrameFormat sound_format,
                        AudioFrameSoundRate sound_rate,
                        AudioFrameSoundSize sound_size,
                        AudioFrameSoundType sound_type,
                        char* frame,
                        int frame_size
                        );
    void AddAudioTimestamp(u_int32_t timestamp);

    /**
     * 获取回调
     */
    RtmpPublisherCallback* GetCallback();

    /**
     * 获取视频编码器
     */
    VideoEncoder* GetVideoEncoder();

    /*
     * 获取音频编码器
     */
    AudioEncoder* GetAudioEncoder();

public:
    void SetCallback(RtmpPublisherCallback* callback);
    void SetVideoEncoder(VideoEncoder* encoder);
    void SetAudioEncoder(AudioEncoder* encoder);

private:
    void OnDisconnect(RtmpDump* rtmpDump);
    void OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int NALUnitHeaderLength);
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
    RtmpPublisherCallback* mpRtmpPublisherCallback;
    
    // Rtmp传输模块
    RtmpDump mRtmpDump;

    // 视频编码器
    VideoEncoder* mpVideoEncoder;
    // 音频编码器
    AudioEncoder* mpAudioEncoder;
};

#endif /* RtmpPublisher_h */
