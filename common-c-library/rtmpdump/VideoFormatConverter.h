//
//  VideoFormatConverter.h
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef VideoFormatConverter_h
#define VideoFormatConverter_h

#include <stdio.h>

#include <rtmpdump/VideoFrame.h>

struct AVCodecContext;
struct AVFrame;
struct SwsContext;

namespace coollive {
class VideoFormatConverter {
public:
    VideoFormatConverter();
    ~VideoFormatConverter();
    
    bool SetDstFormat(VIDEO_FORMATE_TYPE type);
    bool ConvertVideoFrame(VideoFrame* srcFrame, VideoFrame* dstFrame);
    
private:
    // 格式转换Buffer
    VideoFrame mTransBuffer;
    SwsContext *mImgConvertCtx;
    
    int mWidth;
    int mHeight;
    
    // 转换的格式
    int mDstFormat;
};
}
#endif /* VideoFormatConverter_h */
