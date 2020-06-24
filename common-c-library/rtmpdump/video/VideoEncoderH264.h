//
//  VideoEncoderH264.hpp
//  RtmpClient
//
//  Created by Max on 2017/7/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoEncoderH264_h
#define VideoEncoderH264_h

#include <common/KThread.h>

#include <rtmpdump/IEncoder.h>

#include <rtmpdump/util/CacheBufferQueue.h>

#include <rtmpdump/video/VideoFrame.h>
#include <rtmpdump/video/VideoFormatConverter.h>

#include <stdio.h>

#include <string>
using namespace std;

struct AVCodec;
struct AVCodecContext;
struct AVFrame;
struct SwsContext;

namespace coollive {
class VideoFrame;
class ConvertEncodeVideoRunnable;
class EncodeVideoRunnable;

class VideoEncoderH264 : public VideoEncoder {
  public:
    VideoEncoderH264();
    virtual ~VideoEncoderH264();
    static void GobalInit();

  public:
    bool Create(int width, int height, int bitRate, int keyFrameInterval, int fps, VIDEO_FORMATE_TYPE type);
    void SetCallback(VideoEncoderCallback *callback);
    bool Reset();
    void Pause();
    void EncodeVideoFrame(void *data, int size, void *frame);

  private:
    bool Start();
    void Stop();
    void ClearVideoFrame();

    /**
     重采样一个视频帧

     @param srcFrame 输入视频帧
     @param dstFrame 输出视频帧
     @return 成功/失败
     */
    bool ConvertVideoFrame(VideoFrame *srcFrame, VideoFrame *dstFrame);

    /**
     编码一个视频帧

     @param srcFrame 输入视频帧
     @param dstFrame 输出视频帧
     @return 成功/失败
     */
    bool EncodeVideoFrame(VideoFrame *srcFrame, VideoFrame *dstFrame);

  private:
    /**
     创建编码器

     @return <#return value description#>
     */
    bool CreateContext();

    /**
     销毁编码器
     */
    void DestroyContext();

    /**
     释放视频帧Buffer
     
     @param videoFrame 视频帧
     */
    void ReleaseBuffer(VideoFrame *videoFrame);

    /**
     寻找Nalu的开始位置

     @param start 内存块地址
     @param size 内存块大小
     @return nalu地址
     */
    char *FindNalu(char *start, int size, int &startCodeSize);

  private:
    VideoEncoderCallback *mpCallback;

    // 编码器输出参数
    bool mbSpsChange;
    char *mpSps;
    int mSpsSize;
    bool mbPpsChange;
    char *mpPps;
    int mPpsSize;
    int mNaluHeaderSize;

    // 编码参数
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;

    // 编码器句柄
    AVCodec *mCodec;
    AVCodecContext *mContext;

    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;

    // 当前采样帧数
    int mPts;
    //采样的格式
    VIDEO_FORMATE_TYPE mSrcFormat;

    /**************** 重采样相关 ****************/
    // 空闲帧队列
    EncodeDecodeBufferList mFreeBufferList;

    // 格式转换器
    VideoFormatConverter mVideoFormatConverter;

    // 等待重采样队列
    EncodeDecodeBufferList mConvertBufferList;

    // 重采样线程实现体
    friend class ConvertEncodeVideoRunnable;
    ConvertEncodeVideoRunnable *mpConvertEncodeVideoRunnable;
    void ConvertVideoHandle();

    // 编码线程
    KThread mConvertVideoThread;

    /**************** 重采样相关 End ****************/

    /**************** 编码相关 ****************/
    // 等待编码队列
    EncodeDecodeBufferList mEncodeBufferList;

    // 编码线程实现体
    friend class EncodeVideoRunnable;
    EncodeVideoRunnable* mpEncodeVideoRunnable;
    void EncodeVideoHandle();
    
    // 编码线程
    KThread mEncodeVideoThread;
    
    /**************** 编码相关 End ****************/
};
}
#endif /* VideoEncoderH264_h */
