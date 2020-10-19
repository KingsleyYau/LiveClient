

//
//  MediaFileReader.h
//  RtmpClient
//
//  Created by Max on 2020/5/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#ifndef MediaFileReader_h
#define MediaFileReader_h

#include <rtmpdump/IDecoder.h>

#include <common/KMutex.h>
#include <common/KThread.h>
#include <common/KLog.h>

#include <stdio.h>
#include <string>
using namespace std;

struct AVFormatContext;
struct AVCodecContext;

namespace coollive {
class MediaFileReader;
class MediaReaderRunnable;
class MediaFileReaderCallback {
  public:
    virtual ~MediaFileReaderCallback(){};
    virtual void OnMediaFileReaderChangeSpsPps(MediaFileReader *mfr, const char *sps, int sps_size, const char *pps, int pps_size) = 0;
    virtual void OnMediaFileReaderVideoFrame(MediaFileReader *mfr, const char *data, int size, u_int32_t timestamp, VideoFrameType video_type) = 0;
    virtual void OnMediaFileReaderAudioFrame(MediaFileReader *mfr, const char *data, int size, u_int32_t timestamp,
                                             AudioFrameFormat format,
                                             AudioFrameSoundRate sound_rate,
                                             AudioFrameSoundSize sound_size,
                                             AudioFrameSoundType sound_type) = 0;
};

class MediaFileReader {
  public:
    MediaFileReader();
    ~MediaFileReader();

    /**
     播放文件
     
     @param filePath 文件路径
     */
    bool PlayFile(const string &filePath);

    /**
     停止
     */
    void Stop();

    /**
     设置状态回调

     @param pc 状态回调
     */
    void SetMediaFileReaderCallback(MediaFileReaderCallback *callback);

    /**
     设置播放速度

     @param playbackRate 播放速度(原始视频倍数)
     */
    void SetPlaybackRate(float playBackRate);
    
    /**
     设置缓存时间

     @param cacheMS 缓存时间
     */
    void SetCacheMS(int cacheMS);
    
  private:
    // 文件读取线程实现体
    friend class MediaReaderRunnable;
    void MediaReaderHandle();

  private:
    // 状态回调
    MediaFileReaderCallback *mpCallback;

    // 编码器句柄
    AVFormatContext *mContext;

    // 视频流序号
    int mVideoStreamIndex;
    // 视频开始时间戳
    int mVideoStartTimestamp;
    // 视频最新时间戳
    int mVideoLastTimestamp;

    // 音频流序号
    int mAudioStreamIndex;
    // 音频开始时间戳
    int mAudioStartTimestamp;
    // 音频最新时间戳
    int mAudioLastTimestamp;

    // 文件路径
    string mFilePath;

    // 文件读取线程
    KThread mMediaReaderThread;
    MediaReaderRunnable* mpMediaReaderRunnable;
    
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
    
    // 播放速度
    float mPlaybackRate;
    bool mPlaybackRateChange;
    
    // 预加载缓存时间(毫秒)
    unsigned int mCacheMS;
};
}

#endif /* MediaFileReader_h */
