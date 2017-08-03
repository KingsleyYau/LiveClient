//
//  VideoFrame.h
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#ifndef VideoFrame_h
#define VideoFrame_h

#include <rtmpdump/EncodeDecodeBuffer.h>
#include <rtmpdump/ICodec.h>

struct AVFrame;

namespace coollive {
class VideoFrame : public EncodeDecodeBuffer
{
public:
    VideoFrame();
    ~VideoFrame();
    
    VideoFrame(const VideoFrame& item);
    VideoFrame& operator=(const VideoFrame& item);
    
    void ResetFrame();

public:
    int mWidth;                 // 图像宽度
    int mHeight;                // 图像长度
    VideoFrameType mVideoType;  // 类型
    
    AVFrame* mpAVFrame;
};
}
#endif /* VideoFrame_h */
