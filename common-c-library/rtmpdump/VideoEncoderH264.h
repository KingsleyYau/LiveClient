//
//  VideoEncoderH264.hpp
//  RtmpClient
//
//  Created by Max on 2017/7/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoEncoderH264_h
#define VideoEncoderH264_h

#include <stdio.h>

#include <string>
using namespace std;

#include <common/KThread.h>

#include <rtmpdump/IEncoder.h>
#include <rtmpdump/VideoFrame.h>
#include <rtmpdump/CacheBufferQueue.h>
#include <rtmpdump/VideoFormatConverter.h>

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
    
public:
    bool SetSrcFormat(VIDEO_FORMATE_TYPE type);
    
public:
    bool Create(VideoEncoderCallback* callback, int width, int height, int bitRate, int keyFrameInterval, int fps);
    bool Reset();
    void Pause();
    void EncodeVideoFrame(void* data, int size, void* frame);

private:
    /**
     停止编码器
     */
    void Stop();
    
    /**
     释放视频帧Buffer

     @param videoFrame 视频帧
     */
    void ReleaseVideoFrame(VideoFrame* videoFrame);
    
    /**
     重采样一个视频帧

     @param srcFrame 输入视频帧
     @param dstFrame 输出视频帧
     @return 成功/失败
     */
    bool ConvertVideoFrame(VideoFrame* srcFrame, VideoFrame* dstFrame);
    
    /**
     编码一个视频帧

     @param srcFrame 输入视频帧
     @param dstFrame 输出视频帧
     @return 成功/失败
     */
    bool EncodeVideoFrame(VideoFrame* srcFrame, VideoFrame* dstFrame);
    
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
     寻找Nalu的开始位置

     @param start 内存块地址
     @param size 内存块大小
     @return nalu地址
     */
    char* FindNalu(char* start, int size);

private:
    VideoEncoderCallback* mpCallback;
    
    // 编码参数
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;
    
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
    
    // 编码器句柄
    AVCodec *mCodec;
    AVCodecContext *mContext;
    
    // 采样的格式
    int mSrcFormat;
    // 当前采样帧数
    int mPts;
    
    // 空闲帧队列
    EncodeDecodeBufferList mFreeBufferList;

    /**************** 重采样相关 ****************/
    // 格式转换器
    VideoFormatConverter mVideoFormatConverter;
    
    // 等待重采样队列
    EncodeDecodeBufferList mConvertBufferList;
    
    // 重采样线程实现体
    friend class ConvertEncodeVideoRunnable;
    ConvertEncodeVideoRunnable* mpConvertEncodeVideoRunnable;
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
