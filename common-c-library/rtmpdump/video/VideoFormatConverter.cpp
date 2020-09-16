//
//  VideoFormatConverter.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoFormatConverter.h"

#include "VideoFrame.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
}

namespace coollive {
VideoFormatConverter::VideoFormatConverter() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoFormatConverter::VideoFormatConverter( this : %p )", this);

    mDstFormat = VIDEO_FORMATE_BGRA;
    mWidth = 0;
    mHeight = 0;
    mImgConvertCtx = NULL;
}

VideoFormatConverter::~VideoFormatConverter() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoFormatConverter::~VideoFormatConverter( this : %p )", this);

    if (mImgConvertCtx) {
        sws_freeContext(mImgConvertCtx);
        mImgConvertCtx = NULL;
    }
}

void VideoFormatConverter::SetDstFormat(VIDEO_FORMATE_TYPE type) {
    mDstFormat = type;
}

bool VideoFormatConverter::ConvertFrame(VideoFrame *srcFrame, VideoFrame *dstFrame) {
    long long curTime = getCurrentTime();

    AVFrame *srcAvFrame = srcFrame->mpAVFrame;
    AVPixelFormat dstFormat = (AVPixelFormat)VideoFrame::GetPixelFormat(mDstFormat);

    // 改变句柄
    bool bChangeSize = false;
    bool bFlag = ChangeContext(srcFrame, bChangeSize);
    if (bFlag) {
        // 填充原始帧
        AVFrame *pictureFrame = srcFrame->mpAVFrame;
        pictureFrame->format = srcFrame->GetPixelFormat();
        pictureFrame->width = srcFrame->mWidth;
        pictureFrame->height = srcFrame->mHeight;
        avpicture_fill(
            (AVPicture *)pictureFrame,
            (uint8_t *)srcFrame->GetBuffer(),
            (AVPixelFormat)pictureFrame->format,
            pictureFrame->width,
            pictureFrame->height);

        dstFrame->ResetFrame();
        // 复制原始帧参数
        *dstFrame = *srcFrame;

        // 填充dstFrame内容
        int numBytes = avpicture_get_size(dstFormat, mWidth, mHeight);
        dstFrame->RenewBufferSize(numBytes);
        dstFrame->mBufferLen = numBytes;

        uint8_t *buffer = dstFrame->GetBuffer();
        AVFrame *convertFrame = dstFrame->mpAVFrame;
        avpicture_fill(
            (AVPicture *)convertFrame,
            (uint8_t *)buffer,
            dstFormat,
            mWidth,
            mHeight);
        // 开始转换, 数据在dstFrame->mpAvFrame中
        int ret = sws_scale(
            mImgConvertCtx,
            srcAvFrame->data,
            srcAvFrame->linesize,
            0,
            mHeight,
            convertFrame->data,
            convertFrame->linesize);

        if (ret > 0) {
            // 更新帧参数
            dstFrame->mFormat = mDstFormat;
            dstFrame->mWidth = mWidth;
            dstFrame->mHeight = mHeight;

        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoFormatConverter::ConvertFrame( "
                         "[Scacl Frame Fail], "
                         "this : %p, "
                         "ret : %d "
                         ")",
                         bFlag ? "Success" : "Fail",
                         this,
                         ret);
        }
    }

    // 计算处理时间
    long long now = getCurrentTime();
    long long handleTime = now - curTime;
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoFormatConverter::ConvertFrame( "
                 "[Convert Frame %s], "
                 "this : %p, "
                 "srcFrame->mFormat : %d, "
                 "dstFrame->mFormat: %d, "
                 "width : %d, "
                 "height : %d, "
                 "size : %d, "
                 "timestamp : %u, "
                 "handleTime : %lld "
                 ")",
                 bFlag ? "Success" : "Fail",
                 this,
                 srcFrame->mFormat,
                 dstFrame->mFormat,
                 dstFrame->mWidth,
                 dstFrame->mHeight,
                 dstFrame->mBufferLen,
                 dstFrame->mTimestamp,
                 handleTime);

    return bChangeSize;
}

int VideoFormatConverter::GetWidth() {
    return mWidth;
}

int VideoFormatConverter::GetHeight() {
    return mHeight;
}

bool VideoFormatConverter::ChangeContext(VideoFrame *srcFrame, bool &bChangeSize) {
    bool bFlag = false;

    //	AVFrame *frame = srcFrame->mpAVFrame;
    AVPixelFormat srcFormat = (AVPixelFormat)srcFrame->GetPixelFormat();
    AVPixelFormat dstFormat = (AVPixelFormat)VideoFrame::GetPixelFormat(mDstFormat);

    // 创建转换器
    if (mWidth != srcFrame->mWidth || mHeight != srcFrame->mHeight) {
        mWidth = srcFrame->mWidth;
        mHeight = srcFrame->mHeight;

        if (mImgConvertCtx) {
            sws_freeContext(mImgConvertCtx);
            mImgConvertCtx = NULL;
        }

        mImgConvertCtx = sws_getContext(
            mWidth,
            mHeight,
            srcFormat,
            mWidth,
            mHeight,
            dstFormat,
            SWS_BICUBIC, NULL, NULL, NULL);

        FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "VideoFormatConverter::ChangeContext( "
            "[Image Convert Context Change], "
            "this : %p, "
            "width : %d, "
            "height : %d, "
            "srcPixelFormat : %d, "
            "dstPixelFormat : %d "
            ")",
            this,
            mWidth,
            mHeight,
            srcFormat,
            dstFormat);
        
        bChangeSize = true;
    }

    if( mImgConvertCtx ) {
    	bFlag = true;
    }

    return bFlag;
}
    
}
