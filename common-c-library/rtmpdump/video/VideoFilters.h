/*
 * VideoFilters.h
 *
 *  Created on: 2017年8月7日
 *      Author: max
 */

#ifndef RTMPDUMP_VIDEOFILTERS_H_
#define RTMPDUMP_VIDEOFILTERS_H_

#include <common/KThread.h>

#include <rtmpdump/IVideoFilter.h>

#include <rtmpdump/video/VideoRotateFilter.h>
#include <rtmpdump/video/VideoFrame.h>

namespace coollive {
class VideoFilters;
class VideoFiltersCallback {
  public:
    virtual ~VideoFiltersCallback(){};
    virtual void OnFilterVideoFrame(VideoFilters *filters, VideoFrame *videoFrame) = 0;
};

class FilterVideoRunnable;
class VideoFilters {
    typedef list_lock<VideoFilter *> FilterList;

  public:
    VideoFilters();
    virtual ~VideoFilters();

  public:
    void SetFiltersCallback(VideoFiltersCallback *pVideoFiltersCallback);

    bool Start();
    void Stop();

    void AddFilter(VideoFilter *filter);
    void FilterFrame(void *data, int size, int width, int height, VIDEO_FORMATE_TYPE format);

  private:
    bool FilterFrame(VideoFrame *srcFrame, VideoFrame *dstFrame);
    void ReleaseVideoFrame(VideoFrame *videoFrame);

  private:
    // 回调接口
    VideoFiltersCallback *mpVideoFiltersCallback;
    // 过滤器列表
    FilterList mFilterList;

    // 空闲帧队列
    EncodeDecodeBufferList mFreeBufferList;
    // 等待过滤帧队列
    EncodeDecodeBufferList mFilterBufferList;

    // 过滤器Buffer
    VideoFrame mInputFrame;
    VideoFrame mOutputFrame;

    // 过滤器线程实现体
    friend class FilterVideoRunnable;
    FilterVideoRunnable *mpFilterVideoRunnable;
    void FilterVideoHandle();
    // 编码线程
    KThread mFilterVideoThread;

    // 状态锁
    KMutex mRuningMutex;
    bool mbRunning;
};

} /* namespace coollive */

#endif /* RTMPDUMP_VIDEOFILTERS_H_ */
