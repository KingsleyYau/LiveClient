 
        
    
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
    
  private:
    // 文件读取线程实现体
    friend class MediaReaderRunnable;
    void MediaReaderHandle();
    
  private:
    // 编码器句柄
    AVFormatContext *mContext;

    int mVideoStreamIndex;
    int mAudioStreamIndex;

    string mFilePath;
    MediaFileReaderCallback *mpCallback;
    
    // 文件读取线程
    KThread mMediaReaderThread;
    MediaReaderRunnable* mpMediaReaderRunnable;
    
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
};
}

#endif /* MediaFileReader_h */
