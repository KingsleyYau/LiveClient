//
//  VideoFrame.h
//  Camshare
//
//  Created on: 2017-03-27
//      Author: Samson
// Description: 用于存放H264解码后的1帧数据
//

#ifndef VIDEOFRAME_H
#define VIDEOFRAME_H

#include <rtmpdump/ICodec.h>

#include <rtmpdump/util/EncodeDecodeBuffer.h>

// 编解码器默认缓冲帧数
#define DEFAULT_VIDEO_BUFFER_COUNT 30
#define DEFAULT_VIDEO_BUFFER_MAX_COUNT 120
// 编解码器默认视频帧分辨率
#define DEFAULT_VIDEO_BUFFER_SIZE 240 * 320 * 4

struct AVFrame;
namespace coollive {
const static unsigned char sync_bytes[] = {0x0, 0x0, 0x0, 0x1};
class VideoFrame : public EncodeDecodeBuffer {
  public:
    VideoFrame();
    ~VideoFrame();

    VideoFrame(const VideoFrame &item);
    VideoFrame &operator=(const VideoFrame &item);

  public:
    static int GetPixelFormat(VIDEO_FORMATE_TYPE type);

  public:
    void InitFrame(int width, int height, VIDEO_FORMATE_TYPE mFormat);
    void ResetFrame();
    int GetPixelFormat();

  public:
    int mWidth;                 // 图像宽度
    int mHeight;                // 图像长度
    VideoFrameType mVideoType;  // 类型
    VIDEO_FORMATE_TYPE mFormat; // 视频帧采样格式

    AVFrame* mpAVFrame;
};
}
#endif /* VideoFrame_h */
