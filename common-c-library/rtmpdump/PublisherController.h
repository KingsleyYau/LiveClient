//
//  PublisherController.h
//  RtmpClient
//
//  Created by Max on 2017/7/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef PublisherController_h
#define PublisherController_h

#include <stdio.h>

#include <rtmpdump/RtmpDump.h>
#include <rtmpdump/RtmpPublisher.h>
#include <rtmpdump/IEncoder.h>

#include <string>
using namespace std;

namespace coollive {
class PublisherController;
class PublisherStatusCallback {
public:
    virtual ~PublisherStatusCallback() {};
    virtual void OnPublisherConnect(PublisherController* pc) = 0;
    virtual void OnPublisherDisconnect(PublisherController* pc) = 0;
};
    
class PublisherController : public RtmpDumpCallback, VideoEncoderCallback, AudioEncoderCallback {
public:
    PublisherController();
    ~PublisherController();
    
    /**
     设置视频属性
     
     @param width <#width description#>
     @param height <#height description#>
     @param bitRate <#bitRate description#>
     @param keyFrameInterval <#keyFrameInterval description#>
     @param fps <#fps description#>
     */
    void SetVideoParam(int width, int height, int bitRate, int keyFrameInterval, int fps);
    
    /**
     设置音频属性

     @param sampleRate <#sampleRate description#>
     @param channelsPerFrame <#channelsPerFrame description#>
     @param bitPerSample <#bitPerSample description#>
     */
    void SetAudioParam(int sampleRate, int channelsPerFrame, int bitPerSample);
    
    /**
     设置视频编码器
     
     @param videoEncoder 视频编码器
     */
    void SetVideoEncoder(VideoEncoder* videoEncoder);
    /**
     设置音频编码器
     
     @param audioEncoder 音频编码器
     */
    void SetAudioEncoder(AudioEncoder* audioEncoder);
    
    /**
     设置状态回调
     
     @param pc 状态回调
     */
    void SetStatusCallback(PublisherStatusCallback* pc);
    
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
     发送原始视频帧
     
     @param frame 视频帧数据
     */
    void PushVideoFrame(void* data, int size, void* frame);
    
    /**
     发送原始音频帧
     
     @param frame 音频帧数据
     */
    void PushAudioFrame(void* frame);
    
    /**
     增加切换到后台时间造成的timesatmp
     
     @param timestamp <#timestamp description#>
     */
    void AddVideoBackgroundTime(u_int32_t timestamp);
    
private:
    // 编码器回调
    void OnEncodeVideoFrame(VideoEncoder* encoder, char* data, int size, u_int32_t timestamp);
    void OnEncodeAudioFrame(AudioEncoder* encoder,
                            AudioFrameFormat format,
                            AudioFrameSoundRate sound_rate,
                            AudioFrameSoundSize sound_size,
                            AudioFrameSoundType sound_type,
                            char* frame,
                            int size,
                            u_int32_t timestamp
                            );
    
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
    
private:
    // 传输器
    RtmpDump mRtmpDump;
    // 发布器
    RtmpPublisher mRtmpPublisher;
    // 编码器
    VideoEncoder* mpVideoEncoder;
    AudioEncoder* mpAudioEncoder;
    // 状态回调
    PublisherStatusCallback* mpPublisherStatusCallback;
    // 是否使用硬编码码
    bool mUseHardEncoder;
    
    // 视频参数
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;
    
    // 音频参数
    int mSampleRate;
    int mChannelsPerFrame;
    int mBitPerSample;
};
}
#endif /* PublisherController_h */
