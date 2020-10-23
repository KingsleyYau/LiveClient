//
//  VideoHardEncoder.cpp
//  RtmpClient
//
//  Created by Max on 2017/7/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoHardEncoder.h"

#include <common/KLog.h>

namespace coollive {
VideoHardEncoder::VideoHardEncoder() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardEncoder::VideoHardEncoder( this : %p )", this);

    mVideoEncodeQueue = dispatch_queue_create("_mVideoEncodeQueue", NULL);
    mVideoCompressionSession = NULL;
}

VideoHardEncoder::~VideoHardEncoder() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardEncoder::~VideoHardEncoder( this : %p )", this);

    DestroyContext();
}

bool VideoHardEncoder::Create(int width, int height, int bitRate, int keyFrameInterval, int fps, VIDEO_FORMATE_TYPE type) {
    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::Create( this : %p )", this);

    mWidth = width;
    mHeight = height;
    mKeyFrameInterval = keyFrameInterval;
    mBitRate = bitRate;
    mFPS = fps;

    DestroyContext();
    bFlag = CreateContext();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardEncoder::Create( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoHardEncoder::SetCallback(VideoEncoderCallback *callback) {
    mpCallback = callback;
}

bool VideoHardEncoder::Reset() {
    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::Reset( this : %p )", this);
    
    bFlag = CreateContext();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardEncoder::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoHardEncoder::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::Pause( this : %p )", this);

    DestroyContext();
    
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::Pause( this : %p, [Success] )", this);
}

void VideoHardEncoder::EncodeVideoFrame(void *data, int size, void *frame) {
    //    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardEncoder::EncodeVideoFrame( frame : %p )", frame);

    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)frame;
    CVPixelBufferRetain(pixelBuffer);

    dispatch_async(mVideoEncodeQueue, ^{
        mRuningMutex.lock();

        VTEncodeInfoFlags flags;

        // 设置每帧的时间戳
        CMTime presentationTS = CMTimeMake(mEncodeFrameCount++, mFPS);
        double second = (double)(1.0 * presentationTS.value / presentationTS.timescale);
        FileLevelLog("rtmpdump", KLog::LOG_STAT,
                     "VideoHardEncoder::EncodeVideoFrame( this : %p, frame : %p, value : %lld, timescale : %lld )",
                     this,
                     frame,
                     presentationTS.value,
                     presentationTS.timescale);
        OSStatus status = VTCompressionSessionEncodeFrame(
            mVideoCompressionSession,
            pixelBuffer,
            presentationTS,
            kCMTimeInvalid,
            NULL,
            NULL,
            &flags);
        if (status != noErr) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::EncodeVideoFrame( this : %p, [Fail], frame : %p, status : %d )", this, frame, (int)status);
        }

        CVPixelBufferRelease(pixelBuffer);

        mRuningMutex.unlock();
    });
}

void VideoHardEncoder::VideoCompressionOutputCallback(
    void *outputCallbackRefCon,
    void *sourceFrameRefCon,
    OSStatus status,
    VTEncodeInfoFlags infoFlags,
    CMSampleBufferRef sampleBuffer) {
    VideoHardEncoder *encoder = (VideoHardEncoder *)outputCallbackRefCon;
    OSStatus statusCode = noErr;

    if (!sampleBuffer || status != noErr) {
        // kVTVideoEncoderMalfunctionErr
        FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoHardEncoder::VideoCompressionOutputCallback( [sampleBuffer is NULL], status : %ld )", (long)status);

        // 可以断开连接, 或者重建编码器
        return;
    }

    // 计算时间戳
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double value = presentationTime.value;
    value /= presentationTime.timescale;

    CMTime duration = CMSampleBufferGetDuration(sampleBuffer);

    // 第一帧, 或者时间被重置
    if (encoder->mLastPresentationTime == 0 || encoder->mLastPresentationTime > value) {
        encoder->mLastPresentationTime = value;
        encoder->mEncodeStartTS = 0;
    }

    double diff = value - encoder->mLastPresentationTime;
    long int presentTS = (UInt32)lround(1000 * diff);
    encoder->mEncodeStartTS += presentTS;
    UInt32 ts = encoder->mEncodeStartTS;
    encoder->mLastPresentationTime = value;

    // 判断当前帧是否为关键帧
    CFArrayRef arrayRef = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    CFDictionaryRef dictRef = (CFDictionaryRef)CFArrayGetValueAtIndex(arrayRef, 0);
    bool keyframe = !CFDictionaryContainsKey(dictRef, kCMSampleAttachmentKey_NotSync);

    // 关键帧
    if (keyframe) {
        // 获取SPS(Sequence Parameter Set)
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
        if (statusCode == noErr) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardEncoder::VideoCompressionOutputCallback( "
                         "[Encoded SPS], "
                         "ts : %u, "
                         "frameType : 0x%x, "
                         "size : %d "
                         ")",
                         ts,
                         sparameterSet[0],
                         sparameterSetSize);
            encoder->mpCallback->OnEncodeVideoFrame(encoder, (char *)sparameterSet, (int)sparameterSetSize, ts);
        }

        // 获取PPS(Picture Parameter Set)
        size_t pparameterSetSize, pparameterSetCount;
        const uint8_t *pparameterSet;
        statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
        if (statusCode == noErr) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardEncoder::VideoCompressionOutputCallback( "
                         "[Encoded PSP], "
                         "ts : %u, "
                         "frameType : 0x%x, "
                         "size : %d "
                         ")",
                         ts,
                         pparameterSet[0],
                         pparameterSetCount);
            encoder->mpCallback->OnEncodeVideoFrame(encoder, (char *)pparameterSet, (int)pparameterSetSize, ts);
        }
    }

    // 获取编码帧
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *h264Buffer;
    statusCode = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &h264Buffer);
    if (statusCode == noErr) {
        size_t bufferOffset = 0;

        static const char sliceStartCode[] = {0x00, 0x00, 0x01};
        static const int avccHeaderLength = 4;

        // 重置编码Buffer
        encoder->mVideoEncodeFrame.ResetFrame();

        // 硬编码器返回的NALU数据前四个字节不是{0x00, 0x00, 0x00, 0x01}的startcode，而是大端模式的帧长度length
        // 循环获取NALU数据
        while (bufferOffset < totalLength - avccHeaderLength) {
            uint32_t nalUnitLength = 0;

            // Read NALU length
            memcpy(&nalUnitLength, h264Buffer + bufferOffset, avccHeaderLength);

            // 从大端转系统端
            nalUnitLength = CFSwapInt32BigToHost(nalUnitLength);

            char *data = (h264Buffer + bufferOffset + avccHeaderLength);

            if (encoder->mVideoEncodeFrame.mBufferLen != 0) {
                // 增加分片头部
                encoder->mVideoEncodeFrame.AddBuffer((unsigned char *)sliceStartCode, sizeof(sliceStartCode));
            }
            // 填充帧数据
            encoder->mVideoEncodeFrame.AddBuffer((unsigned char *)data, nalUnitLength);

            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardEncoder::VideoCompressionOutputCallback( "
                         "[Encoded Data Slice], "
                         "ts : %u, "
                         "size : %d "
                         ")",
                         ts,
                         nalUnitLength);

            // Move to the next NALU in the block buffer
            bufferOffset += avccHeaderLength + nalUnitLength;
        }

        if (NULL != encoder->mpCallback) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardEncoder::VideoCompressionOutputCallback( "
                         "[Encoded Data], "
                         "ts : %u, "
                         "frameType : 0x%x, "
                         "size : %d "
                         ")",
                         ts,
                         encoder->mVideoEncodeFrame.GetBuffer()[0],
                         encoder->mVideoEncodeFrame.mBufferLen);
            encoder->mpCallback->OnEncodeVideoFrame(encoder, (char *)encoder->mVideoEncodeFrame.GetBuffer(), encoder->mVideoEncodeFrame.mBufferLen, ts);
        }
    }
}

bool VideoHardEncoder::CreateContext() {
    bool bFlag = true;

    mRuningMutex.lock();
    if (!mVideoCompressionSession) {
        bFlag = false;

        OSStatus status;

        int32_t width = (int32_t)mWidth, height = (int32_t)mHeight;
        status = VTCompressionSessionCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCMVideoCodecType_H264,
            NULL,
            NULL,
            NULL,
            VideoCompressionOutputCallback,
            (void *)(this),
            &mVideoCompressionSession);

        if (status == noErr) {
            // 实时流, 快速编码
            VTSessionSetProperty(mVideoCompressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
            // 设置兼容版本
            VTSessionSetProperty(mVideoCompressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);

            // 码率
            SInt32 bitRate = mBitRate;
            CFNumberRef ref = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
            VTSessionSetProperty(mVideoCompressionSession, kVTCompressionPropertyKey_AverageBitRate, ref);
            CFRelease(ref);

            // 关键帧间隔
            int frameInterval = mKeyFrameInterval;
            CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
            VTSessionSetProperty(mVideoCompressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
            CFRelease(frameIntervalRef);

            // 创建编码器
            VTCompressionSessionPrepareToEncodeFrames(mVideoCompressionSession);

            // 初始化时间戳
            mLastPresentationTime = 0;
            mEncodeStartTS = 0;
            mEncodeFrameCount = 0;

        } else {
            FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardEncoder::CreateContext( this : %p, status : %d )", this, (int)status);
        }

        bFlag = (status == noErr);
    }

    mRuningMutex.unlock();

    return bFlag;
}

void VideoHardEncoder::DestroyContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardEncoder::DestroyContext( this : %p )", this);

    mRuningMutex.lock();
    if (mVideoCompressionSession) {
        VTCompressionSessionCompleteFrames(mVideoCompressionSession, kCMTimeInvalid);
        
        VTCompressionSessionInvalidate(mVideoCompressionSession);
        CFRelease(mVideoCompressionSession);
        mVideoCompressionSession = NULL;
    }
    mRuningMutex.unlock();
}
}
