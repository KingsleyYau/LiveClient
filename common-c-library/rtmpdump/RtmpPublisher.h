//
//  RtmpPublisher.h
//  RtmpClient
//
//  Created by Max on 2017/4/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef RtmpPublisher_h
#define RtmpPublisher_h

#include <common/CommonFunc.h>

#include <rtmpdump/RtmpDump.h>

#include <rtmpdump/util/CacheBufferQueue.h>
#include <rtmpdump/util/EncodeDecodeBuffer.h>

#include <stdio.h>

namespace coollive {
class RtmpPublisher;
class RtmpPublisherCallback {
  public:
    virtual ~RtmpPublisherCallback(){};
    virtual void OnVideoBufferFull(RtmpPublisher *publisher) = 0;
};

class PublishRunnable;
class RtmpPublisher {
  public:
    RtmpPublisher(RtmpPublisherCallback *callback = NULL);
    ~RtmpPublisher();

    /**
     发布流连接
     
     @return 成功／失败
     */
    bool PublishUrl();

    /**
     停止
     */
    void Stop();

    /**
     发送原始h264视频帧
     
     @param data 帧数据
     @param size 帧大小
     */
    void SendVideoFrame(char *data, int size, int64_t ts);

    /**
     发送原始音频帧
     
     @param sound_format <#sound_format description#>
     @param sound_rate <#sound_rate description#>
     @param sound_size <#sound_size description#>
     @param sound_type <#sound_type description#>
     @param data <#frame description#>
     @param size <#frame_size description#>
     */
    void SendAudioFrame(AudioFrameFormat sound_format,
                        AudioFrameSoundRate sound_rate,
                        AudioFrameSoundSize sound_size,
                        AudioFrameSoundType sound_type,
                        char *data,
                        int size,
                        int64_t ts);

  public:
    void SetRtmpDump(RtmpDump *rtmpDump);

  private:
    friend class PublishRunnable;
    void PublishHandle();

  private:
    void Init();
    void InitBuffer();

  private:
    // Rtmp传输模块
    RtmpDump *mpRtmpDump;

    // 回调
    RtmpPublisherCallback *mpRtmpPublisherCallback;
    
    // 状态锁
    KMutex mClientMutex;
    bool mbRunning;

    // 发送线程
    KThread mPublishThread;
    PublishRunnable *mpPublishRunnable;

    // 缓存Buffer列表
    EncodeDecodeBufferList mVideoBufferList;
    EncodeDecodeBufferList mAudioBufferList;
    // 空闲的Buffer列表
    CacheBufferQueue mCacheVideoBufferQueue;
    // 空闲的Buffer列表
    CacheBufferQueue mCacheAudioBufferQueue;
};
}
#endif /* RtmpPublisher_h */
