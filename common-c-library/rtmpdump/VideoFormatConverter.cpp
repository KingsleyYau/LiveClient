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
    mDstFormat = AV_PIX_FMT_BGRA;
    mWidth = 0;
    mHeight = 0;
    mImgConvertCtx = NULL;
}

VideoFormatConverter::~VideoFormatConverter() {
    if (mImgConvertCtx) {
        sws_freeContext(mImgConvertCtx);
        mImgConvertCtx = NULL;
    }
}
   
bool VideoFormatConverter::ConvertVideoFrame(VideoFrame* srcFrame, VideoFrame* dstFrame) {
    bool bFlag = true;
    
    long long curTime = getCurrentTime();
    
    AVPixelFormat dstFormat = (AVPixelFormat)mDstFormat;
    AVFrame *decodeFrame = srcFrame->mpAVFrame;
    
    // 创建转换器
    if( mWidth != srcFrame->mWidth || mHeight != srcFrame->mHeight ) {
        mWidth = srcFrame->mWidth;
        mHeight = srcFrame->mHeight;
        
        mImgConvertCtx = sws_getContext(
                                        decodeFrame->width,
                                        decodeFrame->height,
                                        (AVPixelFormat)decodeFrame->format,
                                        decodeFrame->width,
                                        decodeFrame->height,
                                        dstFormat,
                                        SWS_BICUBIC, NULL, NULL, NULL
                                        );
        
        FileLog("rtmpdump",
                "VideoFormatConverter::ConvertVideoFrame( "
                "[Image Convert Context Change], "
                "this : %p, "
                "width : %d, "
                "height : %d, "
                "pixelFormat : %d "
                ")",
                this,
                decodeFrame->width,
                decodeFrame->height,
                decodeFrame->format
                );
    }
    
    // 开始转换
    int numBytes = avpicture_get_size(dstFormat, srcFrame->mWidth, srcFrame->mHeight);
    mTransBuffer.RenewBufferSize(numBytes);
    mTransBuffer.ResetFrame();
    uint8_t* buffer = mTransBuffer.GetBuffer();
    AVFrame *rgbFrame = mTransBuffer.mpAVFrame;
    avpicture_fill((AVPicture *)rgbFrame,
                   (uint8_t *)buffer,
                   dstFormat,
                   srcFrame->mWidth,
                   srcFrame->mHeight
                   );
    
    int height = sws_scale(mImgConvertCtx,
                           decodeFrame->data,
                           decodeFrame->linesize,
                           0,
                           decodeFrame->height,
                           rgbFrame->data,
                           rgbFrame->linesize
                           );
    
    // 复制值
    dstFrame->ResetFrame();
    *dstFrame = *srcFrame;
    
    // 转换格式
    if (mDstFormat == AV_PIX_FMT_YUV420P) {
        // YUV
        // copy Y Data
        int rgbYLen = srcFrame->mWidth * srcFrame->mHeight;
        dstFrame->SetBuffer(rgbFrame->data[0], rgbYLen);
        
        // copy U Data
        int rgbULen = srcFrame->mWidth * srcFrame->mHeight * 1 / 4;
        dstFrame->AddBuffer(rgbFrame->data[1], rgbULen);
        
        // copy V Data
        int rgbVLen = srcFrame->mWidth * srcFrame->mHeight * 1 / 4;
        dstFrame->AddBuffer(rgbFrame->data[2], rgbVLen);
    }
    else {
        // RGB
        dstFrame->SetBuffer(rgbFrame->data[0], numBytes);
    }
    
    // 计算解码时间
    long long now = getCurrentTime();
    long long convertTime = now - curTime;
    
    FileLog("rtmpdump",
            "VideoFormatConverter::ConvertVideoFrame( "
            "[Convert Video Frame], "
            "this : %p, "
            "videoFrame : %p, "
            "timestamp: %u, "
            "convertTime : %lld "
            ")",
            this,
            srcFrame,
            srcFrame->mTimestamp,
            convertTime
            );
    
    return bFlag;
}
    
bool VideoFormatConverter::SetDstFormat(VIDEO_FORMATE_TYPE type) {
    bool result = false;
    switch (type) {
        case VIDEO_FORMATE_BGRA:{
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

}
