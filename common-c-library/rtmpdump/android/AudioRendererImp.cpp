//
//  AudioRendererImp.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioRendererImp.h"
namespace coollive {
AudioRendererImp::AudioRendererImp(jobject jniRenderer) {
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

AudioRendererImp::~AudioRendererImp() {
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

void AudioRendererImp::RenderAudioFrame(void* frame) {
	AudioFrame* audioFrame = (AudioFrame *)frame;

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
			string signure = "([BIII)V";
			jmethodID jMethodID = env->GetMethodID(
					jniRendererCls,
					"renderAudioFrame",
					signure.c_str()
					);

			// 创建新Buffer
			if( dataByteArray != NULL ) {
				int oldLen = env->GetArrayLength(dataByteArray);
				if( oldLen < audioFrame->mBufferLen ) {
					env->DeleteGlobalRef(dataByteArray);
					dataByteArray = NULL;
				}
			}

			if( dataByteArray == NULL ) {
				jbyteArray localDataByteArray = env->NewByteArray(audioFrame->mBufferLen);
				dataByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
				env->DeleteLocalRef(localDataByteArray);
			}

			if( dataByteArray != NULL ) {
				env->SetByteArrayRegion(dataByteArray, 0, audioFrame->mBufferLen, (const jbyte*)audioFrame->GetBuffer());
			}

			// 回调
			if( jMethodID ) {
				int sampleRate = -1;

				switch( audioFrame->mSoundRate ) {
				case AFSR_KHZ_44: {
					sampleRate = 44100;
				}break;
				default:break;
				}

				int channelPerFrame = -1;
				switch( audioFrame->mSoundType ) {
				case AFST_MONO:{
					channelPerFrame = 1;
				}break;
				case AFST_STEREO:{
					channelPerFrame = 2;
				}break;
				default:break;
				}

				int bitPerSample = -1;
				switch( audioFrame->mSoundSize ) {
				case AFSS_BIT_8:{
					bitPerSample = 8;
				}break;
				case AFSS_BIT_16:{
					bitPerSample = 16;
				}break;
				default:break;
				}

				env->CallVoidMethod(mJniRenderer, jMethodID, dataByteArray, sampleRate, channelPerFrame, bitPerSample);
			}

			env->DeleteLocalRef(jniRendererCls);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void AudioRendererImp::Reset() {
    // 播放音频
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 回调PCM帧
	if( mJniRenderer != NULL ) {
		// 反射类
		jclass jniRendererCls = env->GetObjectClass(mJniRenderer);

		if( jniRendererCls != NULL ) {
			// 反射方法
			string signure = "()V";
			jmethodID jMethodID = env->GetMethodID(
					jniRendererCls,
					"reset",
					signure.c_str()
					);

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniRenderer, jMethodID);
			}

			env->DeleteLocalRef(jniRendererCls);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

}
