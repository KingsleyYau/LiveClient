//
//  VideoBuffer.h
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#ifndef VideoBuffer_hpp
#define VideoBuffer_hpp

#include "EncodeDecodeBuffer.h"

class VideoBuffer : public EncodeDecodeBuffer
{
public:
    VideoBuffer();
    ~VideoBuffer();
    
    void ResetFrame();

public:
    int mWidth;                 // 图像宽度
    int mHeight;                // 图像长度
};

#endif /* VideoBuffer_hpp */
