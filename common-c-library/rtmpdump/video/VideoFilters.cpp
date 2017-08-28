/*
 * VideoFilters.cpp
 *
 *  Created on: 2017年8月7日
 *      Author: max
 */

#include "VideoFilters.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

struct AVFrame;
namespace coollive {
// 重采样线程
class FilterVideoRunnable : public KRunnable {
public:
	FilterVideoRunnable(VideoFilters *container) {
        mContainer = container;
    }
    virtual ~FilterVideoRunnable() {
        mContainer = NULL;
    }
protected:
    void onRun() {
        mContainer->FilterVideoHandle();
    }

private:
    VideoFilters *mContainer;
};

VideoFilters::VideoFilters() {
	// TODO Auto-generated constructor stub
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoFilters::VideoFilters( this : %p )", this);

	mpVideoFiltersCallback = NULL;

	mbRunning = false;

	mpFilterVideoRunnable = new FilterVideoRunnable(this);

	Start();
}

VideoFilters::~VideoFilters() {
	// TODO Auto-generated destructor stub
	FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoFilters::~VideoFilters( this : %p )", this);

	Stop();

	if( mpFilterVideoRunnable ) {
		delete mpFilterVideoRunnable;
		mpFilterVideoRunnable = NULL;
	}
}

void VideoFilters::SetFiltersCallback(VideoFiltersCallback *pVideoFiltersCallback) {
	mpVideoFiltersCallback = pVideoFiltersCallback;
}

bool VideoFilters::Start() {
	bool bFlag = true;

    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }

	mbRunning = true;

	VideoFrame* frame = NULL;
	mFreeBufferList.lock();
	for(int i = 0; i < DEFAULT_VIDEO_BUFFER_COUNT; i++) {
		frame = new VideoFrame();
		frame->RenewBufferSize(DEFAULT_VIDEO_BUFFER_SIZE);
		mFreeBufferList.push_back(frame);
	}
	mFreeBufferList.unlock();

	// 开启重采样线程
	mFilterVideoThread.Start(mpFilterVideoRunnable);

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoFilters::Start( "
                 "[%s], "
                 "this : %p "
                 ")",
				 bFlag?"Success":"Fail",
                 this
                 );

    return bFlag;
}

void VideoFilters::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoFilters::Stop( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        mbRunning = false;

        // 停止过滤线程
        mFilterVideoThread.Stop();

        VideoFrame* frame = NULL;
        // 释放未过滤的视频帧
        mFilterBufferList.lock();
        while( !mFilterBufferList.empty() ) {
            frame = (VideoFrame* )mFilterBufferList.front();
            mFilterBufferList.pop_front();
            if( frame != NULL ) {
                delete frame;
            } else {
                break;
            }
        }
        mFilterBufferList.unlock();

        // 释放空闲Buffer
        mFreeBufferList.lock();
        while( !mFreeBufferList.empty() ) {
            frame = (VideoFrame* )mFreeBufferList.front();
            mFreeBufferList.pop_front();
            if( frame != NULL ) {
                delete frame;
            } else {
                break;
            }
        }
        mFreeBufferList.unlock();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoFilters::Stop( "
                 "[Success], "
                 "this : %p "
                 ")",
                 this
                 );
}

void VideoFilters::AddFilter(VideoFilter* filter) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoFilters::AddFilter( "
                "this : %p, "
                "filter : %p "
                ")",
                this,
				filter
                );

	mFilterList.lock();
	mFilterList.push_back(filter);
	mFilterList.unlock();
}

void VideoFilters::FilterFrame(void* data, int size, int width, int height, VIDEO_FORMATE_TYPE format) {
    mFreeBufferList.lock();
    VideoFrame* srcFrame = NULL;
    if( !mFreeBufferList.empty() ) {
        srcFrame = (VideoFrame *)mFreeBufferList.front();
        mFreeBufferList.pop_front();

    } else {
        srcFrame = new VideoFrame();
    }
    mFreeBufferList.unlock();

    srcFrame->InitFrame(width, height, format);
    srcFrame->SetBuffer((unsigned char *)data, size);

    // 放进过滤器队列
    mFilterBufferList.lock();
    mFilterBufferList.push_back(srcFrame);
    mFilterBufferList.unlock();
}

bool VideoFilters::FilterFrame(VideoFrame* srcFrame, VideoFrame* dstFrame) {
	bool bFlag = true;

	long long curTime = getCurrentTime();

	VideoFrame* intputFrame = &mInputFrame;
    VideoFrame* outputFrame = &mOutputFrame;

    // 复制原始帧参数
    *intputFrame = *srcFrame;
    intputFrame->SetBuffer(srcFrame->GetBuffer(), srcFrame->mBufferLen);

	mFilterList.lock();
	for(FilterList::const_iterator itr = mFilterList.begin(); (bFlag && itr != mFilterList.end()); itr++) {
		VideoFilter* filter = *itr;
		bFlag = filter->FilterFrame(intputFrame, outputFrame);
		if( bFlag ) {
			// 切换到下一个
			*intputFrame = *outputFrame;
			intputFrame->SetBuffer(outputFrame->GetBuffer(), outputFrame->mBufferLen);
		}
	}
	mFilterList.unlock();

	// 填充过滤后Buffer
	dstFrame->ResetFrame();
	if( bFlag ) {
		*dstFrame = *intputFrame;
		dstFrame->SetBuffer(intputFrame->GetBuffer(), intputFrame->mBufferLen);
	}

    // 计算处理时间
    long long now = getCurrentTime();
    long long filterTime = now - curTime;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_MSG,
			"VideoFilters::FilterFrame( "
			"[%s], "
			"this : %p, "
			"srcFrame : %p, "
			"width : %d, "
			"height : %d, "
			"size : %d, "
			"filterTime : %lld "
			")",
			bFlag?"Success":"Fail",
			this,
			srcFrame,
			dstFrame->mWidth,
			dstFrame->mHeight,
			dstFrame->mBufferLen,
			filterTime
			);

	return bFlag;
}

void VideoFilters::ReleaseVideoFrame(VideoFrame* videoFrame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoFilters::ReleaseVideoFrame( "
                 "this : %p, "
                 "videoFrame : %p, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
                 videoFrame,
                 mFreeBufferList.size()
                 );

    mFreeBufferList.lock();
    mFreeBufferList.push_back(videoFrame);
    mFreeBufferList.unlock();
}

void VideoFilters::FilterVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoFilters::FilterVideoHandle( "
                "[Start], "
                "this : %p "
                ")",
                this
                );

    VideoFrame* srcFrame = NULL;
    VideoFrame tmpFrame;
    VideoFrame* dstFrame = &tmpFrame;

    while ( mbRunning ) {
        // 获取待过滤帧
        srcFrame = NULL;

        mFilterBufferList.lock();
        if( !mFilterBufferList.empty() ) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoFilters::FilterVideoHandle( "
                         "this : %p, "
                         "mFilterBufferList.size() : %d "
                         ")",
                         this,
						 mFilterBufferList.size()
                         );

            srcFrame = (VideoFrame* )mFilterBufferList.front();
            mFilterBufferList.pop_front();
        }
        mFilterBufferList.unlock();

        if( srcFrame ) {
            // 过滤帧
            if( FilterFrame(srcFrame, dstFrame) ) {
            	if( mpVideoFiltersCallback ) {
            		mpVideoFiltersCallback->OnFilterVideoFrame(this, dstFrame);
            	}
            }

            // 释放待过滤帧
            ReleaseVideoFrame(srcFrame);
        }

        Sleep(1);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoFilters::FilterVideoHandle( "
                "[Exit], "
                "this : %p "
                ")",
                this
                );
}
} /* namespace coollive */
