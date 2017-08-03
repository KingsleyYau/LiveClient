/*
 * LSPublisherImp.cpp
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#include "LSPublisherImp.h"

LSPublisherImp::LSPublisherImp(jobject jniCallback, jobject jniVideoEncoder, int width, int height, int bitRate, int keyFrameInterval, int fps) {
	// TODO Auto-generated constructor stub
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

	mUseHardEncoder = false;
	mpVideoEncoder = NULL;
	mpAudioEncoder = NULL;

	mPublisher.SetStatusCallback(this);
	mPublisher.SetVideoParam(width, height, bitRate, keyFrameInterval, fps);

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	CreateEncoders();
}

LSPublisherImp::~LSPublisherImp() {
	// TODO Auto-generated destructor stub
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

void LSPublisherImp::PushVideoFrame(void* data, int size) {
	FileLog("rtmpdump",
			"LSPublisherImp::PushVideoFrame( "
			"this : %p "
			")",
			this
			);
	mPublisher.PushVideoFrame(data, size, NULL);
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
		VideoHardEncoder* videoEncoder = new VideoHardEncoder(mJniVideoEncoder);
		mpVideoEncoder = videoEncoder;
//		mpAudioEncoder = new AudioEncoderAAC();

	} else {
		// 软解码
		VideoEncoderH264* videoEncoder = new VideoEncoderH264();
		videoEncoder->SetSrcFormat(VIDEO_FORMATE_NV21);
		mpVideoEncoder = videoEncoder;
//		mpAudioEncoder = new AudioEncoderAAC();
	}

    // 替换编码器
	mPublisher.SetVideoEncoder(mpVideoEncoder);
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
}

void LSPublisherImp::OnPublisherConnect(PublisherController* pc) {
	FileLog("rtmpdump",
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
	FileLog("rtmpdump",
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
