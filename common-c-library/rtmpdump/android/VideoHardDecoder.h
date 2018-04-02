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
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength);
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type);
    void ReleaseVideoFrame(void* frame);
    void StartDropFrame();
    
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

    // 解码器变量
    char* mpSps;
    int mSpSize;
    char* mpPps;
    int mPpsSize;
    int mNalUnitHeaderLength;

    jbyteArray spsByteArray;
    jbyteArray ppsByteArray;
    jbyteArray dataByteArray;

    // 解码线程
    KThread mDecodeVideoThread;
    DecodeVideoHardRunnable* mpDecodeVideoRunnable;
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;

    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
};
}

#endif /* VideoHardDecoder_h */
