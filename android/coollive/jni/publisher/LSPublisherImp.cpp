/*
 * LSPublisherImp.cpp
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#include "LSPublisherImp.h"

#include <common/CommonFunc.h>

#include <rtmpdump/video/VideoEncoderH264.h>
#include <rtmpdump/audio/AudioEncoderAAC.h>

#include <rtmpdump/android/VideoHardEncoder.h>
#include <rtmpdump/android/VideoRendererImp.h>

LSPublisherImp::LSPublisherImp(jobject jniCallback, jobject jniVideoEncoder, jobject jniVideoRenderer, int width, int height, int bitRate, int keyFrameInterval, int fps)
:mVideoRotateFilter(fps)
{
	// TODO Auto-generated constructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPublisherImp::LSPublisherImp( this : %p )", this);

    // 视频参数
    mWidth = width;
    mHeight = height;
    mBitRate = bitRate;
    mKeyFrameInterval = keyFrameInterval;
    mFPS = fps;

    // 音频参数
    mSampleRate = 44100;
    mChannelsPerFrame = 1;
    mBitPerSample = 16;

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniCallback = NULL;
	if( jniCallback ) {
		mJniCallback = env->NewGlobalRef(jniCallback);
	}

	mJniVideoEncoder = NULL;
	if( jniVideoEncoder ) {
		mJniVideoEncoder = env->NewGlobalRef(jniVideoEncoder);
	}

	mJniVideoRenderer = NULL;
	if( jniVideoRenderer ) {
		mJniVideoRenderer = env->NewGlobalRef(jniVideoRenderer);
	}

	mUseHardEncoder = false;
	mpVideoEncoder = NULL;
	mpAudioEncoder = NULL;

	mFrameStartTime = 0;
	mFrameIndex = 0;
	mFrameInterval = 8;
	if( fps > 0 ) {
		mFrameInterval = 1000.0 / fps;
	}

	mPublisher.SetStatusCallback(this);
	mPublisher.SetVideoParam(width, height);
//	mPublisher.SetAudioParam(44100, 1, 16);

	mVideoFilters.SetFiltersCallback(this);
	mVideoFilters.AddFilter(&mVideoRotateFilter);

	// 预览格式
	mVideoFormatConverter.SetDstFormat(VIDEO_FORMATE_RGB565);

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	CreateEncoders();
}

LSPublisherImp::~LSPublisherImp() {
	// TODO Auto-generated destructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPublisherImp::~LSPublisherImp( this : %p )", this);

	DestroyEncoders();

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniCallback ) {
		env->DeleteGlobalRef(mJniCallback);
		mJniCallback = NULL;
	}

	if( mJniVideoEncoder ) {
		env->DeleteGlobalRef(mJniVideoEncoder);
		mJniVideoEncoder = NULL;
	}

	if( mJniVideoRenderer ) {
		env->DeleteGlobalRef(mJniVideoRenderer);
		mJniVideoRenderer = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

bool LSPublisherImp::PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath) {
	return mPublisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);
}

void LSPublisherImp::Stop() {
	mPublisher.Stop();

	mFrameStartTime = 0;
	mFrameIndex = 0;
}

void LSPublisherImp::SetUseHardEncoder(bool useHardEncoder) {
	if( mUseHardEncoder != useHardEncoder ) {
		DestroyEncoders();

		mUseHardEncoder = useHardEncoder;

		CreateEncoders();
	}
}

void LSPublisherImp::PushVideoFrame(void* data, int size, int width, int height) {
	long long now = getCurrentTime();
	if( mFrameStartTime == 0 ) {
		mFrameStartTime = now;
	}
    long long diffTime = now - mFrameStartTime;

    // 控制帧率
    if( diffTime >= (mFrameIndex * mFrameInterval) ) {
    	FileLevelLog(
    			"rtmpdump",
    			KLog::LOG_MSG,
    			"LSPublisherImp::PushVideoFrame( "
    			"this : %p, "
    			"diffTime : %lld, "
    			"mFrameIndex : %d "
    			")",
    			this,
    			diffTime,
    			mFrameIndex
    			);

    	mVideoFilters.FilterFrame(data, size, width, height, VIDEO_FORMATE_NV21);
    //	mPublisher.PushVideoFrame(data, size, NULL);
    	// 更新最后处理帧时间
    	mFrameIndex++;
    }
}

void LSPublisherImp::PushAudioFrame(void* data, int size) {
	// 放到推流器
	mPublisher.PushAudioFrame(data, size, NULL);
}

void LSPublisherImp::ChangeVideoRotate(int rotate) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"LSPublisherImp::ChangeVideoRotate( "
			"this : %p, "
			"rotate : %d "
			")",
			this,
			rotate
			);

	mVideoRotateFilter.ChangeRotate(rotate);
}

void LSPublisherImp::CreateEncoders() {
	FileLog("rtmpdump",
			"LSPublisherImp::CreateEncoders( "
			"this : %p, "
			"mUseHardEncoder : %s "
			")",
			this,
			mUseHardEncoder?"true":"false"
			);

	if( mUseHardEncoder ) {
		// 硬编码
		mpVideoEncoder = new VideoHardEncoder(mJniVideoEncoder);;
		mpAudioEncoder = new AudioEncoderAAC();

	} else {
		// 软解码
		mpVideoEncoder = new VideoEncoderH264();
		mpAudioEncoder = new AudioEncoderAAC();
	}

	// 渲染
	mpVideoRenderer = new VideoRendererImp(mJniVideoRenderer);

    // 替换编码器
	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_NV21);
	mPublisher.SetVideoEncoder(mpVideoEncoder);

	mpAudioEncoder->Create(mSampleRate, mChannelsPerFrame, mBitPerSample);
	mPublisher.SetAudioEncoder(mpAudioEncoder);

	FileLog("rtmpdump",
			"LSPublisherImp::CreateEncoders( "
			"[Success], "
			"this : %p, "
			"mUseHardEncoder : %s, "
			"mpVideoEncoder : %p, "
			"mpAudioEncoder : %p "
			")",
			this,
			mUseHardEncoder?"true":"false",
			mpVideoEncoder,
			mpAudioEncoder
			);
}

void LSPublisherImp::DestroyEncoders() {
	FileLog("rtmpdump",
			"LSPublisherImp::DestroyEncoders( "
			"this : %p, "
			"mUseHardEncoder : %s "
			")",
			this,
			mUseHardEncoder?"true":"false"
			);

	if( mpVideoEncoder ) {
		delete mpVideoEncoder;
		mpVideoEncoder = NULL;
	}

	if( mpAudioEncoder ) {
		delete mpAudioEncoder;
		mpAudioEncoder = NULL;
	}

	if( mpVideoRenderer ) {
		delete mpVideoRenderer;
		mpVideoRenderer = NULL;
	}
}

void LSPublisherImp::OnPublisherConnect(PublisherController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"LSPublisherImp::OnPublisherConnect( "
			"this : %p "
			")",
			this
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

//	if( mJniCallback != NULL ) {
//		// 反射类
//		jclass jniCallbackCls = env->GetObjectClass(mJniCallback);
//
//		if( jniCallbackCls != NULL ) {
//			// 发射方法
//			string signure = "()V";
//			jmethodID jMethodID = env->GetMethodID(
//					jniCallbackCls,
//					"onDisconnect",
//					signure.c_str()
//					);
//
//			// 回调
//			if( jMethodID ) {
//				env->CallVoidMethod(mJniCallback, jMethodID);
//			}
//		}
//	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void LSPublisherImp::OnPublisherDisconnect(PublisherController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"LSPublisherImp::OnPublisherConnect( "
			"this : %p "
			")",
			this
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniCallback != NULL ) {
		// 反射类
		jclass jniCallbackCls = env->GetObjectClass(mJniCallback);

		if( jniCallbackCls != NULL ) {
			// 发射方法
			string signure = "()V";
			jmethodID jMethodID = env->GetMethodID(
					jniCallbackCls,
					"onDisconnect",
					signure.c_str()
					);

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniCallback, jMethodID);
			}
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void LSPublisherImp::OnFilterVideoFrame(VideoFilters* filters, VideoFrame* videoFrame) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"LSPublisherImp::OnFilterVideoFrame( "
			"this : %p, "
			"width : %d, "
			"height : %d "
			")",
			this,
			videoFrame->mWidth,
			videoFrame->mHeight
			);

//	// 回调预览, 非常耗时, 需要另外处理
//	mVideoFormatConverter.ConvertFrame(videoFrame, &mPreViewFrame);
//	mpVideoRenderer->RenderVideoFrame(&mPreViewFrame);

	// 放到推流器
	mPublisher.PushVideoFrame(videoFrame->GetBuffer(), videoFrame->mBufferLen, NULL);
}
