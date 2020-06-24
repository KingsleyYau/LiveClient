//
//  VideoFormatConverter.h
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoFormatConverter_h
#define VideoFormatConverter_h

#include <rtmpdump/ICodec.h>

#include <stdio.h>

struct AVCodecContext;
struct AVFrame;
struct SwsContext;

namespace coollive {
class VideoFrame;
class VideoFormatConverter {
  public:
    VideoFormatConverter();
    ~VideoFormatConverter();

  public:
    void SetDstFormat(VIDEO_FORMATE_TYPE type);
    bool ConvertFrame(VideoFrame *srcFrame, VideoFrame *dstFrame);

  private:
    bool ChangeContext(VideoFrame *srcFrame);

  private:
    SwsContext *mImgConvertCtx;

    int mWidth;
    int mHeight;

    // 转换的格式
    VIDEO_FORMATE_TYPE mDstFormat;
};
}
#endif /* VideoFormatConverter_h */
