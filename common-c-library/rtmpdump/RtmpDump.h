//
//  RtmpDump.hpp
//  RtmpClient
//
//  Created by Max on 2017/4/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef RtmpDump_hpp
#define RtmpDump_hpp

#include <common/KMutex.h>
#include <common/KThread.h>
#include <common/KLog.h>

#include <rtmpdump/IDecoder.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <string>
using namespace std;

namespace coollive {
class RtmpDump;
class RtmpDumpCallback {
public:
    virtual ~RtmpDumpCallback(){};
    virtual void OnConnect(RtmpDump* rtmpDump) = 0;
    virtual void OnDisconnect(RtmpDump* rtmpDump) = 0;
    virtual void OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) = 0;
    virtual void OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) = 0;
    virtual void OnChangeAudioFormat(RtmpDump* rtmpDump,
                                     AudioFrameFormat format,
                                     AudioFrameSoundRate sound_rate,
                                     AudioFrameSoundSize sound_size,
                                     AudioFrameSoundType sound_type
                                     ) = 0;
    virtual void OnRecvAudioFrame(RtmpDump* rtmpDump,
                                  AudioFrameFormat format,
                                  AudioFrameSoundRate sound_rate,
                                  AudioFrameSoundSize sound_size,
                                  AudioFrameSoundType sound_type,
                                  char* data,
                                  int size,
                                  u_int32_t timestamp
                                  ) = 0;
};

class RecvRunnable;
class CheckConnectRunnable;
class RtmpDump {
public:
    static void GobalInit();
    
public:
    RtmpDump();
    ~RtmpDump();

    /**
     设置回调

     @param callback 回调
     */
    void SetCallback(RtmpDumpCallback* callback);
    
    /**
     设置推流视频参数

     @param width 视频宽
     @param height 视频高
     */
    void SetVideoParam(int width, int height);
    
    /**
     播放流连接

     @param url 连接
     @param recordFilePath flv录制路径
     @return 成功／失败
     */
    bool PlayUrl(const string& url, const string& recordFilePath);
    
    /**
     发布流连接

     @param url 连接
     @return 成功／失败
     */
    bool PublishUrl(const string& url);
    
    /**
     发送原始h264视频帧

     @param frame 视频帧
     @param frame_size 视频帧大小
     @param timestamp 视频帧时间戳
     @return 成功失败
     */
    bool SendVideoFrame(char* frame, int frame_size, u_int32_t timestamp);
    void AddVideoTimestamp(u_int32_t timestamp);
    
    /**
     发送原始音频帧

     @param sound_format 音频帧格式
     @param sound_rate 音频帧采样率
     @param sound_size 音频帧精度
     @param sound_type 音频帧声道数
     @param frame 音频帧
     @param frame_size 音频帧大小
     @return 成功失败
     */
    bool SendAudioFrame(AudioFrameFormat sound_format,
                        AudioFrameSoundRate sound_rate,
                        AudioFrameSoundSize sound_size,
                        AudioFrameSoundType sound_type,
                        char* frame,
                        int frame_size,
                        u_int32_t timestamp
                        );
    void AddAudioTimestamp(u_int32_t timestamp);
    
    /**
     断开连接
     */
    void Stop();

public:
    // 接收线程处理
    void RecvRunnableHandle();
    // 检查超时线程处理
    void CheckConnectRunnableHandle();
    
private:
    void Destroy();
    bool Flv2Audio(char* frame, int frame_size, u_int32_t timestamp);
    bool Flv2Video(char* frame, int frame_size, u_int32_t timestamp);
    bool FlvVideo2H264(char* frame, int frame_size, u_int32_t timestamp);
    bool GetADTS(int packetSize, char* header, int headerSize);
    u_int32_t GetCurrentTime();
    
    RtmpDumpCallback* mpRtmpDumpCallback;
    
    // srs_rtmp_t 句柄
    void* mpRtmp;
    // srs_flv_t 句柄
    void* mpFlv;
    
    // 录制文件
    string mRecordFlvFilePath;
    
    // 状态锁
    KMutex mClientMutex;
    bool mbRunning;
    
    // 接收线程
    KThread mRecvThread;
    RecvRunnable* mpRecvRunnable;
    
    // 检查连接超时线程
    KThread mCheckConnectThread;
    CheckConnectRunnable* mpCheckConnectRunnable;
    // 连接超时(MS)
    int mConnectTimeout;
    
    // 收包参数
    char* mpSps;
    int mSpsSize;
    
    char* mpPps;
    int mPpsSize;
    
    int mNaluHeaderSize;
    
    // 发包参数
    u_int32_t mEncodeVideoTimestamp;
    u_int32_t mEncodeAudioTimestamp;
    u_int32_t mSendVideoFrameTimestamp;
    u_int32_t mSendAudioFrameTimestamp;
    
    // 是否播放流
    bool mIsPlay;
    // 是否已经连接
    KMutex mConnectedMutex;
    bool mIsConnected;
    
    // 推流视频参数
    int mWidth;
    int mHeight;
};

}
#endif /* RtmpDump_hpp */
