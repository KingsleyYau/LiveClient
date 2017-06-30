//
//  VideoFrame.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include <common/KLog.h>
#include "VideoFrame.h"

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
    
}

VideoFrame& VideoFrame::operator=(const VideoFrame& item) {
    if (this == &item) {
        return *this;
    }
    
    EncodeDecodeBuffer::operator=(item);
    
    mWidth = item.mWidth;
    mHeight = item.mHeight;
    mVideoType = item.mVideoType;
    
    return *this;
}
    
void VideoFrame::ResetFrame() {
	EncodeDecodeBuffer::ResetFrame();

    mWidth = 0;
    mHeight = 0;
    mVideoType = VFT_UNKNOWN;
 
}
}
