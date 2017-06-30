//
//  VideoHardRendererImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoHardRendererImp.h"

#include <rtmpdump/VideoFrame.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
#include <libavutil/imgutils.h>
}

namespace coollive {
VideoHardRendererImp::VideoHardRendererImp(jobject jniRenderer) {
	FileLog("rtmpdump", "VideoHardRendererImp::VideoHardRendererImp( this : %p )", this);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniRenderer = NULL;
	if( jniRenderer ) {
		mJniRenderer = env->NewGlobalRef(jniRenderer);
	}

	dataByteArray = NULL;

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

VideoHardRendererImp::~VideoHardRendererImp() {
	FileLog("rtmpdump", "VideoHardRendererImp::~VideoHardRendererImp( this : %p )", this);
	JNIEnv* env;
	bool isAttachThread;

	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniRenderer ) {
		env->DeleteGlobalRef(mJniRenderer);
		mJniRenderer = NULL;
	}

	if( dataByteArray != NULL ) {
		env->DeleteGlobalRef(dataByteArray);
		dataByteArray = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardRendererImp::RenderVideoFrame(void* frame) {
	VideoFrame* videoFrame = (VideoFrame *)frame;

	FileLog("rtmpdump",
			"VideoHardRendererImp::RenderVideoFrame( "
			"frame : %p, "
			"timestamp : %u "
			")",
			frame,
			videoFrame->mTimestamp
			);

    // 播放视频
	AVPixelFormat srcFormat = AV_PIX_FMT_YUV420P16;
	AVPixelFormat dstFormat = AV_PIX_FMT_RGB565;

	AVFrame* yuvFrame = av_frame_alloc();
	int yuvByteSize = avpicture_get_size(srcFormat, videoFrame->mWidth, videoFrame->mHeight);
	avpicture_fill(
			(AVPicture *)yuvFrame,
			(uint8_t *)videoFrame->GetBuffer(),
			srcFormat,
			videoFrame->mWidth,
			videoFrame->mHeight
			);

	AVFrame* rgbFrame = av_frame_alloc();
	int rgbByteSize = avpicture_get_size(dstFormat, videoFrame->mWidth, videoFrame->mHeight);
	uint8_t* buffer = (uint8_t *)av_malloc(rgbByteSize);
	avpicture_fill(
			(AVPicture *)rgbFrame,
			(uint8_t *)buffer,
			AV_PIX_FMT_RGB565,
			videoFrame->mWidth,
			videoFrame->mHeight
			);

	struct SwsContext *img_convert_ctx = sws_getContext(
			videoFrame->mWidth,
			videoFrame->mHeight,
			srcFormat,
			videoFrame->mWidth,
			videoFrame->mHeight,
			dstFormat,
			SWS_BICUBIC, NULL, NULL, NULL);

	FileLog("rtmpdump",
			"VideoHardRendererImp::RenderVideoFrame( "
			"yuvByteSize : %d, "
			"rgbByteSize : %d "
			")",
			yuvByteSize,
			rgbByteSize
			);

	sws_scale(img_convert_ctx,
			(const uint8_t* const *)yuvFrame->data,
			yuvFrame->linesize,
			0,
			videoFrame->mHeight,
			rgbFrame->data,
			rgbFrame->linesize
			);

	DrawBitmap((char *)rgbFrame->data, rgbByteSize, videoFrame->mWidth, videoFrame->mHeight);

	av_free(buffer);
	av_free(rgbFrame);
	av_free(yuvFrame);
	sws_freeContext(img_convert_ctx);

	FileLog("rtmpdump",
			"VideoHardRendererImp::RenderVideoFrame( "
			"[Success], "
			"frame : %p, "
			"timestamp : %u "
			")",
			frame,
			videoFrame->mTimestamp
			);

}

void VideoHardRendererImp::DrawBitmap(char* data, int size, int width, int height) {
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 回调图像
	if( mJniRenderer != NULL ) {
		// 反射类
		jclass jniRendererCls = env->GetObjectClass(mJniRenderer);
		if( jniRendererCls != NULL ) {
			// 发射方法
			string signure = "([BII)V";
			jmethodID jMethodID = env->GetMethodID(
					jniRendererCls,
					"renderVideoFrame",
					signure.c_str()
					);

			// 创建新Buffer
			if( dataByteArray != NULL ) {
				int oldLen = env->GetArrayLength(dataByteArray);
				if( oldLen < size ) {
					env->DeleteGlobalRef(dataByteArray);
					dataByteArray = NULL;
				}
			}

			if( dataByteArray == NULL ) {
				jbyteArray localDataByteArray = env->NewByteArray(size);
				dataByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
				env->DeleteLocalRef(localDataByteArray);
			}

			if( dataByteArray != NULL ) {
				env->SetByteArrayRegion(dataByteArray, 0, size, (const jbyte*)data);
			}

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniRenderer, jMethodID, dataByteArray, width, height);
			}

			env->DeleteLocalRef(jniRendererCls);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

}
