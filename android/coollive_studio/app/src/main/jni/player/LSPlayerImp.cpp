/*
 * LSPlayerImp.cpp
 *
 *  Created on: 2017年6月19日
 *      Author: max
 */

#include <LSPlayerImp.h>
#include "../LSVersion.h"

LSPlayerImp::LSPlayerImp(
		jobject jniCallback,
		jboolean useHardDecoder,
		jobject jniVideoRenderer,
		jobject jniAudioRenderer,
		jobject jniVideoHardDecoder,
		jobject jniVideoHardRenderer
		) {
	// TODO Auto-generated constructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPlayerImp::LSPlayerImp( this : %p )", this);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniCallback = NULL;
	if( jniCallback ) {
		mJniCallback = env->NewGlobalRef(jniCallback);
	}

	mJniVideoRenderer = NULL;
	if( jniVideoRenderer ) {
		mJniVideoRenderer = env->NewGlobalRef(jniVideoRenderer);
	}

	mJniAudioRenderer = NULL;
	if( jniAudioRenderer ) {
		mJniAudioRenderer = env->NewGlobalRef(jniAudioRenderer);
	}

	mJniVideoHardDecoder = NULL;
	if( jniVideoHardDecoder ) {
		mJniVideoHardDecoder = env->NewGlobalRef(jniVideoHardDecoder);
	}

	mJniVideoHardRenderer = NULL;
	if( jniVideoHardRenderer ) {
		mJniVideoHardRenderer = env->NewGlobalRef(jniVideoHardRenderer);
	}

	mUseHardDecoder = useHardDecoder;

	mPlayer.SetStatusCallback(this);

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	CreateDecoders();
}

LSPlayerImp::~LSPlayerImp() {
	// TODO Auto-generated destructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPlayerImp::~LSPlayerImp( this : %p )", this);

	DestroyDecoders();

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniCallback ) {
		env->DeleteGlobalRef(mJniCallback);
		mJniCallback = NULL;
	}

	if( mJniVideoRenderer ) {
		env->DeleteGlobalRef(mJniVideoRenderer);
		mJniVideoRenderer = NULL;
	}

	if( mJniAudioRenderer ) {
		env->DeleteGlobalRef(mJniAudioRenderer);
		mJniAudioRenderer = NULL;
	}

	if( mJniVideoHardDecoder ) {
		env->DeleteGlobalRef(mJniVideoHardDecoder);
		mJniVideoHardDecoder = NULL;
	}

	if( mJniVideoHardRenderer ) {
		env->DeleteGlobalRef(mJniVideoHardRenderer);
		mJniVideoHardRenderer = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

bool LSPlayerImp::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
	return mPlayer.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
}

void LSPlayerImp::Stop() {
	mPlayer.Stop();
}

void LSPlayerImp::SetUseHardDecoder(bool useHardDecoder) {
	if( mUseHardDecoder != useHardDecoder ) {
		DestroyDecoders();

		mUseHardDecoder = useHardDecoder;

		CreateDecoders();
	}
}

void LSPlayerImp::CreateDecoders() {
	FileLog("rtmpdump",
			"LSPlayerImp::CreateDecoders( "
			"player : %p, "
			"mUseHardDecoder : %s "
			")",
			this,
			mUseHardDecoder?"true":"false"
			);

	if( mUseHardDecoder ) {
		// 硬解码
		VideoHardDecoder* videoDecoder = new VideoHardDecoder(mJniVideoHardDecoder);
		mpVideoDecoder = videoDecoder;
		mpAudioDecoder = new AudioDecoderAAC();

		// 硬渲染
		mpVideoRenderer = new VideoHardRendererImp(mJniVideoHardRenderer);
		mpAudioRenderer = new AudioRendererImp(mJniAudioRenderer);

	} else {
		// 软解码
		VideoDecoderH264* videoDecoder = new VideoDecoderH264();
//		videoDecoder->SetDecoderVideoFormat(VIDEO_FORMATE_RGB565);
		videoDecoder->SetDecoderVideoFormat(VIDEO_FORMATE_RGBA);
		mpVideoDecoder = videoDecoder;
		mpAudioDecoder = new AudioDecoderAAC();

		// 软渲染
		mpVideoRenderer = new VideoRendererImp(mJniVideoRenderer);
		mpAudioRenderer = new AudioRendererImp(mJniAudioRenderer);
	}

	mPlayer.SetVideoDecoder(mpVideoDecoder);
	mPlayer.SetAudioDecoder(mpAudioDecoder);
	mPlayer.SetVideoRenderer(mpVideoRenderer);
	mPlayer.SetAudioRenderer(mpAudioRenderer);

	FileLog("rtmpdump",
			"LSPlayerImp::CreateDecoders( "
			"[Success], "
			"player : %p, "
			"mUseHardDecoder : %s, "
			"mpVideoDecoder : %p, "
			"mpAudioDecoder : %p, "
			"mpVideoRenderer : %p, "
			"mpAudioRenderer : %p "
			")",
			this,
			mUseHardDecoder?"true":"false",
			mpVideoDecoder,
			mpAudioDecoder,
			mpVideoRenderer,
			mpAudioRenderer
			);
}

void LSPlayerImp::DestroyDecoders() {
	FileLog("rtmpdump",
			"LSPlayerImp::DestroyDecoders( "
			"player : %p, "
			"mUseHardDecoder : %s "
			")",
			this,
			mUseHardDecoder?"true":"false"
			);

	if( mpVideoDecoder ) {
		delete mpVideoDecoder;
		mpVideoDecoder = NULL;
	}

	if( mpAudioDecoder ) {
		delete mpAudioDecoder;
		mpAudioDecoder = NULL;
	}

	if( mpVideoRenderer ) {
		delete mpVideoRenderer;
		mpVideoRenderer = NULL;
	}

	if( mpAudioRenderer ) {
		delete mpAudioRenderer;
		mpAudioRenderer = NULL;
	}
}

void LSPlayerImp::OnPlayerConnect(PlayerController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerImp::OnPlayerConnect( "
			"player : %p "
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

void LSPlayerImp::OnPlayerDisconnect(PlayerController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerImp::OnPlayerDisconnect( "
			"player : %p "
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

void LSPlayerImp::OnPlayerOnDelayMaxTime(PlayerController* pc) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_MSG,
			"LSPlayerImp::OnPlayerOnDelayMaxTime( "
			"player : %p "
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
					"onPlayerOnDelayMaxTime",
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

void LSPlayerImp::OnPlayerInfoChange(PlayerController *pc, int videoDisplayWidth, int vieoDisplayHeight) {

}

void LSPlayerImp::OnPlayerStats(PlayerController *pc, unsigned int fps, unsigned int bitrate) {

}

void LSPlayerImp::OnPlayerError(PlayerController *pc, const string& code, const string& description) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::OnPlayerError( "
			"this : %p, "
			"code : %s, "
			"description : %s "
			")",
			this,
			code.c_str(),
			description.c_str()
			);
}

void LSPlayerImp::OnPlayerFinish(PlayerController *pc) {

}