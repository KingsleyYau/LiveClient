//
//  VideoBuffer.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include <common/KLog.h>
#include "VideoBuffer.h"

VideoBuffer::VideoBuffer() {
    mWidth = 0;
    mHeight = 0;
}

VideoBuffer::~VideoBuffer() {
}

void VideoBuffer::ResetFrame() {
	EncodeDecodeBuffer::ResetFrame();

    mWidth = 0;
    mHeight = 0;
}
