//
//  VideoFormatConverter.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoFormatConverter.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
}

namespace coollive {
VideoFormatConverter::VideoFormatConverter() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoFormatConverter::VideoFormatConverter( this : %p )", this);
    
    mDstFormat = AV_PIX_FMT_BGRA;
    mWidth = 0;
    mHeight = 0;
    mImgConvertCtx = NULL;
}

VideoFormatConverter::~VideoFormatConverter() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoFormatConverter::~VideoFormatConverter( this : %p )", this);
    
    if (mImgConvertCtx) {
        sws_freeContext(mImgConvertCtx);
        mImgConvertCtx = NULL;
    }
}
    
bool VideoFormatConverter::SetDstFormat(VIDEO_FORMATE_TYPE type) {
    bool result = false;
    switch (type) {
        case VIDEO_FORMATE_BGRA: {
            mDstFormat = AV_PIX_FMT_BGRA;
            result = true;
        }break;
        case VIDEO_FORMATE_RGB565: {
            mDstFormat = AV_PIX_FMT_RGB565;
            result = true;
        }break;
        case VIDEO_FORMATE_RGB24: {
            mDstFormat = AV_PIX_FMT_RGB24;
            result = true;
        }break;
        case VIDEO_FORMATE_YUV420P: {
            mDstFormat = AV_PIX_FMT_YUV420P;
            result = true;
        }break;
        default:
            break;
    }
    return result;
}
    
bool VideoFormatConverter::ConvertDecodeFrame(VideoFrame* srcFrame, VideoFrame* dstFrame) {
    bool bFlag = true;
    
//    long long curTime = getCurrentTime();
    
    AVFrame *decodeFrame = srcFrame->mpAVFrame;
    AVPixelFormat dstFormat = (AVPixelFormat)mDstFormat;
    
    ChangeContext(decodeFrame);
    
    // 填充临时帧
    int numBytes = avpicture_get_size(dstFormat, mWidth, mHeight);
    mTransBuffer.RenewBufferSize(numBytes);
    mTransBuffer.ResetFrame();
    uint8_t* buffer = mTransBuffer.GetBuffer();
    AVFrame *convertFrame = mTransBuffer.mpAVFrame;
    avpicture_fill(
                   (AVPicture *)convertFrame,
                   (uint8_t *)buffer,
                   dstFormat,
                   mWidth,
                   mHeight
                   );
    // 开始转换, 数据在临时帧中
    int height = sws_scale(mImgConvertCtx,
                           decodeFrame->data,
                           decodeFrame->linesize,
                           0,
                           mHeight,
                           convertFrame->data,
                           convertFrame->linesize
                           );
    
    // 复制帧参数
    dstFrame->ResetFrame();
    *dstFrame = *srcFrame;
    
    // 复制帧数据
    if (dstFormat == AV_PIX_FMT_YUV420P) {
        // YUV
        // copy Y Data
        int rgbYLen = mWidth * mHeight;
        dstFrame->SetBuffer(convertFrame->data[0], rgbYLen);
        
        // copy U Data
        int rgbULen = mWidth * mHeight * 1 / 4;
        dstFrame->AddBuffer(convertFrame->data[1], rgbULen);
        
        // copy V Data
        int rgbVLen = mWidth * mHeight * 1 / 4;
        dstFrame->AddBuffer(convertFrame->data[2], rgbVLen);
    }
    else {
        // RGB
        dstFrame->SetBuffer(convertFrame->data[0], numBytes);
    }
    
//    // 计算处理时间
//    long long now = getCurrentTime();
//    long long convertTime = now - curTime;
//    FileLog("rtmpdump",
//            "VideoFormatConverter::ConvertVideoFrame( "
//            "[Convert Frame], "
//            "this : %p, "
//            "videoFrame : %p, "
//            "timestamp: %u, "
//            "convertTime : %lld "
//            ")",
//            this,
//            srcFrame,
//            srcFrame->mTimestamp,
//            convertTime
//            );
    
    return bFlag;
}

bool VideoFormatConverter::ConvertEncodeFrame(VideoFrame* srcFrame, VideoFrame* dstFrame) {
    bool bFlag = true;
    
    long long curTime = getCurrentTime();
    
    AVFrame *captureFrame = srcFrame->mpAVFrame;
    AVPixelFormat dstFormat = (AVPixelFormat)mDstFormat;
    
    ChangeContext(captureFrame);
    
    // 填充dstFrame
    int numBytes = avpicture_get_size(dstFormat, mWidth, mHeight);
    dstFrame->RenewBufferSize(numBytes);
    dstFrame->ResetFrame();
    uint8_t* buffer = dstFrame->GetBuffer();
    AVFrame *convertFrame = dstFrame->mpAVFrame;
    avpicture_fill(
                   (AVPicture *)convertFrame,
                   (uint8_t *)buffer,
                   dstFormat,
                   mWidth,
                   mHeight
                   );
    // 开始转换, 数据在dstFrame->mpAvFrame中
    int height = sws_scale(mImgConvertCtx,
                           captureFrame->data,
                           captureFrame->linesize,
                           0,
                           mHeight,
                           convertFrame->data,
                           convertFrame->linesize
                           );
    // 复制帧参数
    *dstFrame = *srcFrame;
    
    // 计算处理时间
    long long now = getCurrentTime();
    long long convertTime = now - curTime;
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoFormatConverter::ConvertEncodeFrame( "
                "[Convert Frame], "
                "this : %p, "
                "srcFrame : %p, "
                "dstFrame: %p, "
                "convertTime : %lld "
                ")",
                this,
                srcFrame,
                dstFrame,
                convertTime
                );
    
    return bFlag;
}
    
void VideoFormatConverter::ChangeContext(AVFrame *frame) {
    AVPixelFormat srcFormat = (AVPixelFormat)frame->format;
    AVPixelFormat dstFormat = (AVPixelFormat)mDstFormat;
    
    // 创建转换器
    if( mWidth != frame->width || mHeight != frame->height ) {
        mWidth = frame->width;
        mHeight = frame->height;
        
        mImgConvertCtx = sws_getContext(
                                        mWidth,
                                        mHeight,
                                        srcFormat,
                                        mWidth,
                                        mHeight,
                                        dstFormat,
                                        SWS_BICUBIC, NULL, NULL, NULL
                                        );
        
        FileLevelLog(
                     "rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoFormatConverter::ChangeContext( "
                     "[Image Convert Context Change], "
                     "this : %p, "
                     "width : %d, "
                     "height : %d, "
                     "srcFormat : %d, "
                     "dstFormat : %d "
                     ")",
                     this,
                     mWidth,
                     mHeight,
                     srcFormat,
                     dstFormat
                     );
    }
}
    
}
