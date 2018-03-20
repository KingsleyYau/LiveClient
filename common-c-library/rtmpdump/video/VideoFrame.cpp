//
//  VideoFrame.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include "VideoFrame.h"

#include "VideoFormatConverter.h"

#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
}

namespace coollive {
VideoFrame::VideoFrame() {
    mpAVFrame = av_frame_alloc();
    
    ResetFrame();
}

VideoFrame::~VideoFrame() {
    if( mpAVFrame ) {
        av_free(mpAVFrame);
        mpAVFrame = NULL;
    }
}
    
VideoFrame::VideoFrame(const VideoFrame& item)
:EncodeDecodeBuffer(item) {
    mpAVFrame = av_frame_alloc();
    
    ResetFrame();

    mWidth = item.mWidth;
    mHeight =  item.mHeight;
    mVideoType = item.mVideoType;
    mFormat = item.mFormat;
}

VideoFrame& VideoFrame::operator=(const VideoFrame& item) {
    if (this == &item) {
        return *this;
    }
    
    EncodeDecodeBuffer::operator=(item);

    mWidth = item.mWidth;
    mHeight = item.mHeight;
    mVideoType = item.mVideoType;
    mFormat = item.mFormat;

    return *this;
}

void VideoFrame::InitFrame(int width, int height, VIDEO_FORMATE_TYPE format) {
	mWidth = width;
	mHeight = height;
	mFormat = format;
}

void VideoFrame::ResetFrame() {
	EncodeDecodeBuffer::ResetBuffer();

    mWidth = 0;
    mHeight = 0;
    mVideoType = VFT_UNKNOWN;
    mFormat = VIDEO_FORMATE_NONE;
}

int VideoFrame::GetPixelFormat() {
	return GetPixelFormat(mFormat);
}

int VideoFrame::GetPixelFormat(VIDEO_FORMATE_TYPE type) {
	int format = -1;
    switch (type) {
		case VIDEO_FORMATE_NV21: {
			format = AV_PIX_FMT_NV21;
		}break;
		case VIDEO_FORMATE_NV12: {
			format = AV_PIX_FMT_NV12;
		}break;
        case VIDEO_FORMATE_YUV420P: {
        	format = AV_PIX_FMT_YUV420P;
        }break;
        case VIDEO_FORMATE_RGB565: {
        	format = AV_PIX_FMT_RGB565;
        }break;
        case VIDEO_FORMATE_RGB24: {
        	format = AV_PIX_FMT_RGB24;
        }break;
        case VIDEO_FORMATE_BGRA: {
        	format = AV_PIX_FMT_RGBA;
        }break;
        case VIDEO_FORMATE_RGBA: {
            format = AV_PIX_FMT_RGBA;
        }break;
        default:
            break;
    }
    return format;
}

}
