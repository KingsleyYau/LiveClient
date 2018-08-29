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

LSPublisherImp::LSPublisherImp(
		jobject jniCallback,
		jboolean useHardEncoder,
		jobject jniVideoEncoder,
		int width,
		int height,
		int bitRate,
		int keyFrameInterval,
		int fps
		)
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

	mpVideoEncoder = NULL;
	mpAudioEncoder = NULL;

	mPublisher.SetStatusCallback(this);
	mPublisher.SetVideoParam(width, height, fps, keyFrameInterval);

	mUseHardEncoder = useHardEncoder;

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

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

bool LSPublisherImp::PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath) {
	return mPublisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);
}

void LSPublisherImp::Stop() {
	mPublisher.Stop();
}

void LSPublisherImp::SetUseHardEncoder(bool useHardEncoder) {
	if( mUseHardEncoder != useHardEncoder ) {
		DestroyEncoders();

		mUseHardEncoder = useHardEncoder;

		CreateEncoders();
	}
}

void LSPublisherImp::PushVideoFrame(void* data, int size, int width, int height) {
    // 放到推流器
    mPublisher.PushVideoFrame(data, size, NULL);
}

void LSPublisherImp::PausePushVideo() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::PausePushVideo( "
			"this : %p "
			")",
			this
			);
    mPublisher.PausePushVideo();
}

void LSPublisherImp::ResumePushVideo() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::ResumePushVideo( "
			"this : %p "
			")",
			this
			);
    mPublisher.ResumePushVideo();
}

void LSPublisherImp::PushAudioFrame(void* data, int size) {
	// 放到推流器
	mPublisher.PushAudioFrame(data, size, NULL);
}

void LSPublisherImp::ChangeVideoRotate(int rotate) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::ChangeVideoRotate( "
			"this : %p, "
			"rotate : %d "
			")",
			this,
			rotate
			);
//	mVideoRotateFilter.ChangeRotate(rotate);
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
		mpVideoEncoder = new VideoHardEncoder(mJniVideoEncoder);
		mpAudioEncoder = new AudioEncoderAAC();

	} else {
		// 软解码
		mpVideoEncoder = new VideoEncoderH264();
		mpAudioEncoder = new AudioEncoderAAC();
	}

    // 替换编码器
//	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_NV21);
//	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_RGB565);
	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_RGBA);
	mPublisher.SetVideoEncoder(mpVideoEncoder);

	mpAudioEncoder->Create(mSampleRate, mChannelsPerFrame, mBitPerSample);
	mPublisher.SetAudioEncoder(mpAudioEncoder);

	FileLog("rtmpdump",
			"LSPublisherImp::CreateEncoders( "
			"this : %p, "
			"[Success], "
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
}

void LSPublisherImp::OnPublisherConnect(PublisherController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
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
					"onConnect",
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

void LSPublisherImp::OnPublisherDisconnect(PublisherController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::OnPublisherDisconnect( "
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
