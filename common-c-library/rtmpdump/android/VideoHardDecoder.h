//
//  VideoHardDecoder.h
//  RtmpClient
//
//  Created by  Max on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  视频硬解码实现类

#ifndef VideoHardDecoder_h
#define VideoHardDecoder_h

#include <rtmpdump/IDecoder.h>
#include <rtmpdump/video/VideoFrame.h>
#include <rtmpdump/video/VideoMuxer.h>
#include <rtmpdump/util/EncodeDecodeBuffer.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <common/KThread.h>

namespace coollive {
class DecodeVideoHardRunnable;
class RtmpPlayer;
class VideoHardDecoder : public VideoDecoder {
public:
    VideoHardDecoder();
    VideoHardDecoder(jobject jniDecoder);
    virtual ~VideoHardDecoder();

public:
    bool Create(VideoDecoderCallback* callback);
    bool Reset();
    void Pause();
    void ResetStream();
    void DecodeVideoKeyFrame(const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, int64_t ts, const char *vps = NULL, int vps_size = 0);
    void DecodeVideoFrame(const char *data, int size, int64_t dts, int64_t pts, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    void ClearVideoFrame();
    
protected:
    void Init();
    bool Start();
    void Stop();

private:
    // 解码线程实现体
    friend class DecodeVideoHardRunnable;
    void DecodeVideoHandle();

private:
    VideoDecoderCallback* mpCallback;
    jobject mJniDecoder;
    jmethodID mJniDecoderResetMethodID;
    jmethodID mJniDecoderPauseMethodID;
    jmethodID mJniDecoderGetDecodeVideoMethodID;
    jmethodID mJniDecoderDecodeKeyMethodID;
    jmethodID mJniDecoderDecodeVideoMethodID;
    jmethodID mJniDecoderReleaseMethodID;

    jfieldID mJniVideoFrameTimestampMethodID;
    jfieldID mJniVideoFrameErrorMethodID;

    // 解码器变量
    char* mpSps;
    int mSpSize;
    char* mpPps;
    int mPpsSize;
    int mNaluHeaderSize;

    jbyteArray spsByteArray;
    jbyteArray ppsByteArray;
    jbyteArray dataByteArray;
    VideoFrame mVideoFrame;

    // 解码线程
    KThread mDecodeVideoThread;
    DecodeVideoHardRunnable* mpDecodeVideoRunnable;
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
    // H264格式转换器
    VideoMuxer mVideoMuxer;
};
}

#endif /* VideoHardDecoder_h */
