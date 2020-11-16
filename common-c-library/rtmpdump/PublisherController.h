//
//  PublisherController.h
//  RtmpClient
//
//  Created by Max on 2017/7/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef PublisherController_h
#define PublisherController_h

#include <rtmpdump/RtmpDump.h>
#include <rtmpdump/RtmpPublisher.h>
#include <rtmpdump/IEncoder.h>

#include <rtmpdump/video/VideoRecorderH264.h>
#include <rtmpdump/audio/AudioRecorderAAC.h>

#include <stdio.h>

#include <string>
using namespace std;

namespace coollive {
class PublisherController;
class PublisherStatusCallback {
  public:
    virtual ~PublisherStatusCallback(){};
    virtual void OnPublisherConnect(PublisherController *pc) = 0;
    virtual void OnPublisherDisconnect(PublisherController *pc) = 0;
    virtual void OnPublisherError(PublisherController *pc, const string& code, const string& description) = 0;
};

class PublisherController : public RtmpDumpCallback, VideoEncoderCallback, AudioEncoderCallback {
  public:
    PublisherController();
    ~PublisherController();

    /**
     设置视频编码器
     
     @param videoEncoder 视频编码器
     */
    void SetVideoEncoder(VideoEncoder *videoEncoder);
    /**
     设置音频编码器
     
     @param audioEncoder 音频编码器
     */
    void SetAudioEncoder(AudioEncoder *audioEncoder);

    /**
     设置状态回调
     
     @param pc 状态回调
     */
    void SetStatusCallback(PublisherStatusCallback *pc);

    /**
     设置推流视频参数
     
     @param width 视频宽
     @param height 视频高
     @param fps 帧率
     @param keyInterval 关键帧间隔
     */
    void SetVideoParam(int width, int height, int fps, int keyInterval);

    /**
     发布流连接
     
     @param url 连接
     @param recordH264FilePath H264录制路径
     @param recordAACFilePath AAC录制路径
     @return 成功／失败
     */
    bool PublishUrl(const string &url, const string &recordH264FilePath, const string &recordAACFilePath);

    /**
     停止
     */
    void Stop();

    /**
     发送原始视频帧
     
     @param frame 视频帧数据
     */
    void PushVideoFrame(void *data, int size, void *frame = NULL);

    /**
     发送原始音频帧
     
     @param frame 音频帧数据
     */
    void PushAudioFrame(void *data, int size, void *frame = NULL);

    /**
     暂停推送视频
     */
    void PausePushVideo();

    /**
     恢复推送视频
     */
    void ResumePushVideo();

    /**
     增加采集视频卡顿造成的时间
     
     @param ts 采集视频卡顿造成的时间
     */
    void AddVideoTimestamp(u_int32_t ts);

    /**
     发送Login命令

     @return 发送结果
     */
    bool SendCmdLogin(const string &userName, const string &password, const string &siteId);
    /**
     发送MakeCall命令

     @return 发送结果
     */
    bool SendCmdMakeCall(const string &userName, const string &serverId, const string &siteId);

  private:
    // 编码器回调
    void OnEncodeVideoFrame(VideoEncoder *encoder, char *data, int size, int64_t ts);
    void OnEncodeAudioFrame(AudioEncoder *encoder,
                            AudioFrameFormat format,
                            AudioFrameSoundRate sound_rate,
                            AudioFrameSoundSize sound_size,
                            AudioFrameSoundType sound_type,
                            char *frame,
                            int size,
                            int64_t ts);

  private:
    // 传输器回调
    void OnConnect(RtmpDump *rtmpDump);
    void OnDisconnect(RtmpDump *rtmpDump);
    void OnChangeVideoSpsPps(RtmpDump *rtmpDump, const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, u_int32_t ts);
    void OnRecvVideoFrame(RtmpDump *rtmpDump, const char *data, int size, u_int32_t pts, u_int32_t dts, VideoFrameType video_type);
    void OnChangeAudioFormat(RtmpDump *rtmpDump,
                             AudioFrameFormat format,
                             AudioFrameSoundRate sound_rate,
                             AudioFrameSoundSize sound_size,
                             AudioFrameSoundType sound_type);
    void OnRecvAudioFrame(RtmpDump *rtmpDump,
                          AudioFrameFormat format,
                          AudioFrameSoundRate sound_rate,
                          AudioFrameSoundSize sound_size,
                          AudioFrameSoundType sound_type,
                          char *data,
                          int size,
                          u_int32_t ts);
    void OnRecvCmdLogin(RtmpDump *rtmpDump,
                        bool bFlag,
                        const string &userName,
                        const string &serverAddress);
    void OnRecvCmdMakeCall(RtmpDump *rtmpDump,
                           const string &uuId,
                           const string &userName);
    void OnRecvStatusError(RtmpDump *rtmpDump,
                           const string &code,
                           const string &description);
    
  private:
    // 传输器
    RtmpDump mRtmpDump;

    // 发布器
    RtmpPublisher mRtmpPublisher;

    // 编码器
    VideoEncoder *mpVideoEncoder;
    AudioEncoder *mpAudioEncoder;

    // 状态回调
    PublisherStatusCallback *mpPublisherStatusCallback;

    // 录制模块
    VideoRecorderH264 mVideoRecorderH264;
    AudioRecorderAAC mAudioRecorderAAC;

    // 视频控制
    KMutex mPublisherMutex;
    // 第一次处理帧时间
    long long mVideoFrameStartPushTime;
    long long mVideoFrameLastPushTime;
    // 由期望帧率得出的帧间隔(ms)
    int mVideoFps;
    int mVideoFrameInterval;
    // 由实际帧率得出的帧间隔(ms)
    int mVideoFpsExact;
    int mVideoFrameIntervalExact;
    
    int mVideoFrameIndex;
    // 视频是否暂停采集
    bool mVideoPause;
    // 视频是否已经恢复采集
    bool mVideoResume;
};
}
#endif /* PublisherController_h */
