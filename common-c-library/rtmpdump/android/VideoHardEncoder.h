//
//  VideoHardEncoder.h
//  RtmpClient
//
//  Created by  Max on 07/27/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  视频硬解码实现类

#ifndef VideoHardEncoder_h
#define VideoHardEncoder_h

#include <rtmpdump/IEncoder.h>

#include <rtmpdump/util/EncodeDecodeBuffer.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <common/KThread.h>

namespace coollive {
class EncodeVideoHardRunnable;
class RtmpPublisher;
class VideoHardEncoder : public VideoEncoder {
public:
	VideoHardEncoder();
	VideoHardEncoder(jobject jniEncoder);
    virtual ~VideoHardEncoder();

public:
    bool Create(int width, int height, int bitRate, int keyFrameInterval, int fps, VIDEO_FORMATE_TYPE type);
    void SetCallback(VideoEncoderCallback* callback);
    bool Reset();
    void Pause();
    void EncodeVideoFrame(void* data, int size, void* frame);
    
private:
    /**
     * 初始化
     */
    void Init();
    bool Start();
    void Stop();
    char* FindNalu(char* start, int size, int& startCodeSize);

private:
    // 编码线程实现体
    friend class EncodeVideoHardRunnable;
    void EncodeVideoHandle();

private:
    VideoEncoderCallback* mpCallback;
    jobject mJniEncoder;
    jmethodID mJniEncoderResetMethodID;
    jmethodID mJniEncoderPauseMethodID;
    jmethodID mJniEncoderGetEncodeVideoMethodID;
    jmethodID mJniEncoderEncodeVideoMethodID;
    jmethodID mJniEncoderReleaseMethodID;

    jfieldID mJniVideoFrameTimestampMethodID;
    jfieldID mJniVideoFrameDataMethodID;
    jfieldID mJniVideoFrameSizeMethodID;

    // 编码器变量
    int mWidth;
    int mHeight;
    int mBitRate;
    int mKeyFrameInterval;
    int mFPS;

    jbyteArray dataByteArray;

    // 编码线程
    KThread mEncodeVideoThread;
    EncodeVideoHardRunnable* mpEncodeVideoRunnable;
    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;

    // 空闲Buffer
    EncodeDecodeBufferList mFreeBufferList;
};
}

#endif /* VideoHardEncoder_h */
