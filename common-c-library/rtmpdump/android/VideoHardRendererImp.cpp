//
//  VideoHardRendererImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoHardRendererImp.h"
#include "JavaItem.h"

#include <rtmpdump/video/VideoFrame.h>

#include <common/KLog.h>

namespace coollive {
VideoHardRendererImp::VideoHardRendererImp(jobject jniRenderer) {
	FileLog("rtmpdump", "VideoHardRendererImp::VideoHardRendererImp( this : %p )", this);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniRenderer = NULL;
	if( jniRenderer ) {
		mJniRenderer = env->NewGlobalRef(jniRenderer);
		jclass jniRendererCls = env->GetObjectClass(mJniRenderer);
		// 反射方法
		string signure = "(L" LS_VIDEO_ITEM_CLASS ";)V";
		jmethodID jMethodID = env->GetMethodID(
				jniRendererCls,
				"renderVideoFrame",
				signure.c_str()
				);
		mJniRendererMethodID = jMethodID;
	}

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

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardRendererImp::RenderVideoFrame(void* frame) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"VideoHardRendererImp::RenderVideoFrame( "
			"frame : %p "
			")",
			frame
			);

    // 播放视频
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	jobject jVideoFrame = (jobject)frame;
	// 回调图像
	if( mJniRenderer != NULL ) {
		// 回调
		if( mJniRendererMethodID ) {
			env->CallVoidMethod(mJniRenderer, mJniRendererMethodID, jVideoFrame);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

}
