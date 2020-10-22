//
//  Statistics.h
//  RtmpClient
//  统计流播放信息类
//  Created by Max on 2017/6/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef Statistics_h
#define Statistics_h

#include <common/KMutex.h>

#include <stdio.h>

namespace coollive {

class Statistics {
  public:
    Statistics();
    ~Statistics();

    void Start();
    void Stop();

    /**
     增加视频帧
     */
    bool AddVideoRecvFrame(int size);
    bool AddVideoPlayFrame();

    /**
     增加音频帧
     */
    void AddAudioRecvFrame();
    void AddAudioPlayFrame();

    /**
     是否需要丢弃视频帧

     @return 是否
     */
    bool IsDropVideoFrame();

    /**
     是否需要断开

     @return <#return value description#>
     */
    int IsDisconnect();

    unsigned int Fps();
    unsigned int Bitrate();
    void SetOriginalFps(unsigned int fps);
    unsigned int OriginalFps();
    
  private:
    /**
     是否接收视频帧
     
     @return 是否
     */
    bool CanRecvVideo();
    /**
     是否接收视频帧
     
     @return 是否
     */
    bool CanRecvAudio();

  private:
    // 状态锁
    KMutex mStatusMutex;
    bool mbRunning;

    int mVideoRecvFrameCount;
    int mVideoPlayFrameCount;
    int mAudioRecvFrameCount;
    int mAudioPlayFrameCount;
    
    // 统计帧率
    unsigned int mVideoPlayFrameCountPre;
    long long mFpsTime;
    unsigned int mFps;
    unsigned int mOriginalFps;
    
    // 统计码率
    long long mVideoRecvBytesPre;
    long long mVideoRecvBytes;
    long long mVideoBytesTime;
    unsigned int mBitrate;
    
};
    
}
#endif /* Statistics_h */
