//
//  VideoRenderImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoRendererImp.h"
namespace coollive {
VideoRendererImp::VideoRendererImp(jobject jniRenderer) {
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

VideoRendererImp::~VideoRendererImp() {
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

void VideoRendererImp::RenderVideoFrame(void* frame) {
	VideoFrame* videoFrame = (VideoFrame *)frame;

//	FileLog("rtmpdump",
//			"VideoRendererImp::RenderVideoFrame( "
//			"frame : %p, "
//			"timestamp : %u "
//			")",
//			frame,
//			videoFrame->mTimestamp
//			);

    // 播放视频
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
				if( oldLen < videoFrame->mBufferLen ) {
					env->DeleteGlobalRef(dataByteArray);
					dataByteArray = NULL;
				}
			}

			if( dataByteArray == NULL ) {
				jbyteArray localDataByteArray = env->NewByteArray(videoFrame->mBufferLen);
				dataByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
				env->DeleteLocalRef(localDataByteArray);
			}

			if( dataByteArray != NULL ) {
				env->SetByteArrayRegion(dataByteArray, 0, videoFrame->mBufferLen, (const jbyte*)videoFrame->GetBuffer());
			}

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniRenderer, jMethodID, dataByteArray, videoFrame->mWidth, videoFrame->mHeight);
			}

			env->DeleteLocalRef(jniRendererCls);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

//	FileLog("rtmpdump",
//			"VideoRendererImp::RenderVideoFrame( "
//			"[Success], "
//			"frame : %p, "
//			"timestamp : %u "
//			")",
//			frame,
//			videoFrame->mTimestamp
//			);
}

}
