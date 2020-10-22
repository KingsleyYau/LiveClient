//
//  FrameBuffer.h
//  Camshare
//
//  Created on: 2017-04-14
//      Author: Max
// Description: 用于存放解码后的音视频帧
//

#ifndef FrameBuffer_hpp
#define FrameBuffer_hpp

#include <stdio.h>
#include <common/list_lock.h>

namespace coollive {
class FrameBuffer
{
public:
    FrameBuffer();
    FrameBuffer(void* frame, int64_t timestamp);
    ~FrameBuffer();
    
public:
    void* mpFrame;
    int64_t mTS;    // 帧时间戳
};

// list define
typedef list_lock<FrameBuffer*> FrameBufferList;

}
#endif /* FrameBuffer_hpp */
