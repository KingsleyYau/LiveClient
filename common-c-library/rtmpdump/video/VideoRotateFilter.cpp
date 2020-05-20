/*
 * VideoRotateFilter.cpp
 *
 *  Created on: 2017年8月4日
 *      Author: max
 */

#include "VideoRotateFilter.h"

#include "VideoFrame.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
#include <libavutil/opt.h>
//#include <libavfilter/avfiltergraph.h>
#include <libavfilter/buffersink.h>
#include <libavfilter/buffersrc.h>
}

namespace coollive {

#define INVALID_WIDTH -1
#define INVALID_HEIGHT -1

VideoRotateFilter::VideoRotateFilter(int fps) {
	// TODO Auto-generated constructor stub
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoRotateFilter::VideoRotateFilter( this : %p, fps : %d )", this, fps);

    avfilter_register_all();

    mFilterGraph = NULL;
    mBufferSrcCtx = NULL;
    mRotateCtx = NULL;
    mBufferSinkCtx = NULL;

    mFormat = VIDEO_FORMATE_NONE;
    mWidth = INVALID_WIDTH;
    mHeight = INVALID_HEIGHT;
    mFps = fps;
    mRotateAngle = 0;
}

VideoRotateFilter::~VideoRotateFilter() {
	// TODO Auto-generated destructor stub
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoRotateFilter::~VideoRotateFilter( this : %p )", this);

	DestroyFilter();
}

bool VideoRotateFilter::FilterFrame(VideoFrame* srcFrame, VideoFrame* dstFrame) {
	bool bFlag = false;
	int ret = 0;
	char errbuf[1024];

	long long curTime = getCurrentTime();

	// 创建句柄
	bFlag = ChangeFilter(srcFrame);
	if( bFlag ) {
		bFlag = false;

	    AVFrame* inputFrame = srcFrame->mpAVFrame;
	    inputFrame->format = srcFrame->GetPixelFormat();
	    inputFrame->width = srcFrame->mWidth;
	    inputFrame->height = srcFrame->mHeight;

	    ret = avpicture_fill(
	                   (AVPicture *)inputFrame,
	                   (uint8_t *)srcFrame->GetBuffer(),
					   (AVPixelFormat)srcFrame->GetPixelFormat(),
					   inputFrame->width,
					   inputFrame->height
	                   );

	    ret = av_buffersrc_add_frame_flags(mBufferSrcCtx, inputFrame, AV_BUFFERSRC_FLAG_KEEP_REF);
	    if( ret < 0 ) {
	    	av_strerror(ret, errbuf, sizeof(errbuf));
	        FileLevelLog(
	        		"rtmpdump",
	        		KLog::LOG_WARNING,
	        		"VideoRotateFilter::FilterFrame( "
	        		"[Error while feeding the data], "
	        		"this : %p, "
	    			"ret : %d, "
					"errbuf : %s, "
					"format : %d, "
					"width : %d, "
					"height : %d "
	        		")",
	    			this,
	    			ret,
					errbuf,
					inputFrame->format,
					inputFrame->width,
					inputFrame->height
	    			);
	    }

	    AVFrame* outputFrame = dstFrame->mpAVFrame;
	    ret = av_buffersink_get_frame(mBufferSinkCtx, outputFrame);
		if ( ret >= 0 ) {
			bFlag = true;

		} else {
			av_strerror(ret, errbuf, sizeof(errbuf));
			FileLevelLog(
					"rtmpdump",
					KLog::LOG_WARNING,
					"VideoRotateFilter::FilterFrame( "
					"[Error while getting frame], "
					"this : %p, "
					"ret : %d, "
					"errbuf : %s "
					")",
					this,
					ret,
					errbuf
					);
		}

		if( bFlag ) {
			AVPicture* picture = (AVPicture *)outputFrame;
			int destSize = avpicture_get_size((AVPixelFormat)inputFrame->format, outputFrame->width, outputFrame->height);

			// 填充帧内容
	    	dstFrame->ResetFrame();
			dstFrame->RenewBufferSize(destSize);
			dstFrame->mBufferLen = destSize;
			avpicture_layout(picture, (AVPixelFormat)inputFrame->format, outputFrame->width, outputFrame->height, dstFrame->GetBuffer(), destSize);

		    // 更新帧参数
		    *dstFrame = *srcFrame;
		    dstFrame->mWidth = outputFrame->width;
		    dstFrame->mHeight = outputFrame->height;

			av_frame_unref(outputFrame);
		}

		av_frame_unref(inputFrame);
	}

    // 计算处理时间
    long long now = getCurrentTime();
    long long filterTime = now - curTime;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"VideoRotateFilter::FilterFrame( "
			"[%s], "
			"this : %p, "
			"format : %d, "
			"width : %d, "
			"height : %d, "
			"size : %d, "
			"filterTime : %lld "
			")",
			bFlag?"Success":"Fail",
			this,
			dstFrame->mFormat,
			dstFrame->mWidth,
			dstFrame->mHeight,
			dstFrame->mBufferLen,
			filterTime
			);

	return bFlag;
}

bool VideoRotateFilter::ChangeRotate(int rotate) {
	bool bFlag = true;

	if( mRotateAngle != rotate ) {
		mRotateAngle = rotate;

		FileLevelLog("rtmpdump",
				KLog::LOG_WARNING,
				"VideoRotateFilter::ChangeRotate( "
				"this : %p, "
				"mRotateAngle : %d, "
				"mFormat : %d, "
				"mWidth : %d, "
				"mHeight : %d "
				")",
				this,
				mRotateAngle,
				mFormat,
				mWidth,
				mHeight
				);

		if( mWidth != INVALID_WIDTH && mHeight != INVALID_HEIGHT && mFormat != VIDEO_FORMATE_NONE ) {
			VideoFrame frame;
			frame.mWidth = mWidth;
			frame.mHeight = mHeight;
			frame.mFormat = mFormat;

			DestroyFilter();
			bFlag = CreateFilter(&frame);
		}
	}

	return bFlag;
}

bool VideoRotateFilter::ChangeFilter(VideoFrame* srcFrame) {
	bool bFlag = true;

	if( mWidth != srcFrame->mWidth || mHeight != srcFrame->mHeight || mFormat != srcFrame->mFormat ) {
		FileLevelLog("rtmpdump",
				KLog::LOG_WARNING,
				"VideoRotateFilter::ChangeFilter( "
				"this : %p, "
				"mFormat : %d, "
				"mWidth : %d, "
				"mHeight : %d, "
				"srcFrame->mFormat : %d, "
				"srcFrame->mWidth : %d, "
				"srcFrame->mHeight : %d, "
				"srcFrame->GetPixelFormat() : %d "
				")",
				this,
				mFormat,
				mWidth,
				mHeight,
				srcFrame->mFormat,
				srcFrame->mWidth,
				srcFrame->mHeight,
				srcFrame->GetPixelFormat()
				);

		DestroyFilter();
		bFlag = CreateFilter(srcFrame);
	}

	return bFlag;
}

bool VideoRotateFilter::CreateFilter(VideoFrame* srcFrame) {
	bool bFlag = true;

	int pixelFormat = srcFrame->GetPixelFormat();
    mFormat = srcFrame->mFormat;
    mWidth = srcFrame->mWidth;
    mHeight = srcFrame->mHeight;

	FileLevelLog("rtmpdump",
			KLog::LOG_MSG,
			"VideoRotateFilter::CreateFilter( "
			"this : %p, "
			"pixelFormat : %d, "
			"width : %d, "
			"height : %d "
			")",
			this,
			pixelFormat,
			mWidth,
			mHeight
			);

	if( !mFilterGraph ) {
		mFilterGraph = avfilter_graph_alloc();
	} else {
		FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [avfilter_graph_alloc Fail], this : %p )", this);
		bFlag = false;
	}

	// 创建过滤器
	char args[256];
	int ret = 0;
	if( bFlag ) {
		if( !mBufferSrcCtx ) {
			snprintf(args, sizeof(args),
					"video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d",
					mWidth,
					mHeight,
					pixelFormat,
					1,
					mFps,
					mWidth,
					mHeight
					);
			const AVFilter *buffersrc = avfilter_get_by_name("buffer");
			FileLevelLog(
					"rtmpdump",
					KLog::LOG_MSG,
					"VideoRotateFilter::CreateFilter( "
					"[Create mBufferSrcCtx], "
					"this : %p, "
					"buffersrc : %p, "
					"args : %s "
					")",
					this,
					buffersrc,
					args
					);

			if( 0 != (ret = avfilter_graph_create_filter(&mBufferSrcCtx, buffersrc, "buffer", args, NULL, mFilterGraph)) ) {
				FileLevelLog(
						"rtmpdump",
						KLog::LOG_ERR_USER,
						"VideoRotateFilter::CreateFilter( "
						"[Create mBufferSrcCtx Fail], "
						"this : %p, "
						"ret : %d "
						")",
						this,
						ret
						);
				bFlag = false;
			}
		} else {
			bFlag = false;
		}
	}

	if( bFlag ) {
		if( !mRotateCtx ) {
			// mRotateAngle为需要的逆时针旋转角度, (输入源为顺时针旋转)
			int angle = 0;
			switch( mRotateAngle ) {
			case 90:{
				angle = 3;
			}break;
			case 180:{
				angle = 2;
			}break;
			case 270:{
				angle = 1;
			}break;
			default:{
				angle = 0;
			}break;
			}

			snprintf(args, sizeof(args), "%d", angle);
			const AVFilter *transpose = avfilter_get_by_name("transpose");
			FileLevelLog(
					"rtmpdump",
					KLog::LOG_MSG,
					"VideoRotateFilter::CreateFilter( "
					"[Create mRotateCtx], "
					"this : %p, "
					"transpose : %p, "
					"args : %s "
					")",
					this,
					transpose,
					args
					);

			if( 0 != avfilter_graph_create_filter(&mRotateCtx, transpose, "transpose", args, NULL, mFilterGraph) ) {
				FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [Create mRotateAngle Fail], this : %p )", this);
				bFlag = false;
			}
		} else {
			bFlag = false;
		}
	}

	if( bFlag ) {
		if( !mBufferSinkCtx ) {
			const AVFilter *buffersink = avfilter_get_by_name("buffersink");
			FileLevelLog(
					"rtmpdump",
					KLog::LOG_ERR_USER,
					"VideoRotateFilter::CreateFilter( "
					"[Create mBufferSinkCtx], "
					"this : %p, "
					"buffersink : %p "
					")",
					this,
					buffersink
					);

			if( 0 != avfilter_graph_create_filter(&mBufferSinkCtx, buffersink, "buffersink", NULL, NULL, mFilterGraph) ) {
				FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [Create mBufferSinkCtx Fail], this : %p )", this);
				bFlag = false;
			}
		} else {
			bFlag = false;
		}
	}

	// 连接过滤器
	if( bFlag ) {
		if( 0 != avfilter_link(mBufferSrcCtx, 0, mRotateCtx, 0) ) {
			FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [Link {mBufferSrcCtx, mRotateCtx} Fail], this : %p )", this);
			bFlag = false;
		}

	}
	if( bFlag ) {
		if( 0 != avfilter_link(mRotateCtx, 0, mBufferSinkCtx, 0) ) {
			FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [Link {mRotateCtx, mBufferSinkCtx} Fail], this : %p )", this);
			bFlag = false;
		}
	}

	if( bFlag ) {
		if( avfilter_graph_config(mFilterGraph, NULL) != 0) {
			FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "VideoRotateFilter::CreateFilter( [Check config Fail], this : %p )", this);
			bFlag = false;
		}
	}

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"VideoRotateFilter::CreateFilter( "
			"[%s], this : %p "
			")",
			bFlag?"Success":"Fail",
			this
			);

	return bFlag;
}

void VideoRotateFilter::DestroyFilter() {
	FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoRotateFilter::DestroyFilter( this : %p )", this);

	if( !mFilterGraph ) {
		avfilter_graph_free(&mFilterGraph);
		mFilterGraph = NULL;
	}

    if ( mBufferSrcCtx ) {
        av_free(mBufferSrcCtx);
        mBufferSrcCtx = NULL;
    }

    if ( mRotateCtx ) {
        av_free(mRotateCtx);
        mRotateCtx = NULL;
    }

    if ( mBufferSinkCtx ) {
        av_free(mBufferSinkCtx);
        mBufferSinkCtx = NULL;
    }
}

} /* namespace coollive */
