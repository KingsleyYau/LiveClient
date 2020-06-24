/*
 * VideoRotateFilter.h
 *
 *  Created on: 2017年8月4日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEOROTATEFILTER_H_
#define RTMPDUMP_VIDEOROTATEFILTER_H_

#include <stdio.h>

#include <rtmpdump/IVideoFilter.h>
#include <rtmpdump/ICodec.h>

struct AVFilterGraph;
struct AVFilterContext;
struct AVFilter;

namespace coollive {
class VideoRotateFilter : public VideoFilter {
  public:
    VideoRotateFilter(int fps);
    virtual ~VideoRotateFilter();

  public:
    bool FilterFrame(VideoFrame *srcFrame, VideoFrame *dstFrame);
    bool ChangeRotate(int rotate);

  private:
    bool ChangeFilter(VideoFrame *srcFrame);
    bool CreateFilter(VideoFrame *srcFrame);
    void DestroyFilter();

  private:
    AVFilterGraph *mFilterGraph;
    // 过滤器头
    AVFilterContext *mBufferSrcCtx;
    // 过滤器(旋转)
    AVFilterContext *mRotateCtx;
    // 过滤器尾
    AVFilterContext *mBufferSinkCtx;

    VIDEO_FORMATE_TYPE mFormat;
    int mWidth;
    int mHeight;
    int mFps;
    int mRotateAngle;
};

} /* namespace coollive */

#endif /* RTMPDUMP_VIDEOROTATEFILTER_H_ */
