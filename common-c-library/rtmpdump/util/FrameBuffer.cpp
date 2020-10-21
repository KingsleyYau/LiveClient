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
    mTS = 0;
}

FrameBuffer::FrameBuffer(void* frame, unsigned int ts) {
    mpFrame = frame;
    mTS = ts;
}
    
FrameBuffer::~FrameBuffer() {
    
}
}
