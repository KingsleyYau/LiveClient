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
class PublishRunnable;
class RtmpPublisher {
public:
	RtmpPublisher();
    ~RtmpPublisher();
    
    /**
     发布流连接
     
     @param url 连接
     @return 成功／失败
     */
    bool PublishUrl(const string& url);
    
    /**
     停止
     */
    void Stop();

    /**
     发送原始h264视频帧
     
     @param data <#frame description#>
     @param size <#frame_size description#>
     */
    void SendVideoFrame(char* data, int size, u_int32_t timestamp);
  
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
                        char* data,
                        int size,
                        u_int32_t timestamp
                        );
    
public:
    void SetRtmpDump(RtmpDump* rtmpDump);
    
private:
    friend class PublishRunnable;
    void PublishHandle();
    
private:
    void Init();
    void InitBuffer();
    
private:
    // Rtmp传输模块
    RtmpDump* mpRtmpDump;
    
    // 状态锁
    KMutex mClientMutex;
    bool mbRunning;
    
    // 发送线程
    KThread mPublishThread;
    PublishRunnable* mpPublishRunnable;
    
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
