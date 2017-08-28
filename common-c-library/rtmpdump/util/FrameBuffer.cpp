//
//  FrameBuffer.cpp
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#include "FrameBuffer.h"

namespace coollive {
FrameBuffer::FrameBuffer() {
    mpFrame = NULL;
    mTimestamp = 0;
}

FrameBuffer::FrameBuffer(void* frame, unsigned int timestamp) {
    mpFrame = frame;
    mTimestamp = timestamp;
}
    
FrameBuffer::~FrameBuffer() {
    
}
}
