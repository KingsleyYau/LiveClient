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
		int fps,
		int keyFrameInterval,
		int bitrate
		)
{
	// TODO Auto-generated constructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPublisherImp::LSPublisherImp( this : %p )", this);

    // 视频参数
    mWidth = width;
    mHeight = height;
    mBitrate = bitrate;
    mKeyFrameInterval = keyFrameInterval;
    mFPS = fps;

    // 音频参数
    mSampleRate = 44100;
    mChannelsPerFrame = 1;
    mBitPerSample = 16;

    mUseHardEncoder = useHardEncoder;
	mpVideoEncoder = NULL;
	mpAudioEncoder = NULL;

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

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	CreateEncoders();

	mPublisher.SetStatusCallback(this);
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
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::PublishUrl( "
			"this : %p, "
			"url : %s "
			")",
			this,
			url.c_str()
			);

	bool bFlag = mPublisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);

    FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "LSPublisherImp::PublishUrl( "
            "this : %p, "
            "[%s], "
            "url : %s "
            ")",
            this,
            bFlag?"Success":"Fail",
            url.c_str()
            );

	return bFlag;
}

void LSPublisherImp::Stop() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::Stop( "
			"this : %p "
			")",
			this
			);

	mPublisher.Stop();

    FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "LSPublisherImp::Stop( "
            "this : %p, "
            "[Success] "
            ")",
            this
            );
}

bool LSPublisherImp::UpdateVideoParam(int width, int height, int fps, int keyFrameInterval, int bitrate) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::UpdateVideoParam( "
			"this : %p, "
            "width : %d, "
            "height : %d, "
            "fps : %d, "
            "keyFrameInterval : %d, "
            "bitrate : %d "
			")",
			this,
            width,
            height,
            fps,
            keyFrameInterval,
            bitrate
			);

    // 视频参数
    mWidth = width;
    mHeight = height;
    mBitrate = bitrate;
    mKeyFrameInterval = keyFrameInterval;
    mFPS = fps;

    bool bFlag = mPublisher.SetVideoParam(mWidth, mHeight, mFPS, mKeyFrameInterval, mBitrate, VIDEO_FORMATE_RGBA);

    FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "LSPublisherJni::UpdateVideoParam( "
            "this : %p, "
            "[%s], "
            "width : %d, "
            "height : %d, "
            "fps : %d, "
            "keyFrameInterval : %d, "
            "bitrate : %d "
            ")",
            this,
            bFlag?"Success":"Fail",
            width,
            height,
            fps,
            keyFrameInterval,
            bitrate
            );

	return bFlag;
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
    mPublisher.PausePushVideo();
}

void LSPublisherImp::ResumePushVideo() {
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

	mPublisher.SetAudioEncoder(mpAudioEncoder);
	mPublisher.SetVideoEncoder(mpVideoEncoder);
	mpAudioEncoder->Create(mSampleRate, mChannelsPerFrame, mBitPerSample);
	mPublisher.SetVideoParam(mWidth, mHeight, mFPS, mKeyFrameInterval, mBitrate, VIDEO_FORMATE_RGBA);

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

void LSPublisherImp::OnPublisherError(PublisherController *pc, const string& code, const string& description) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherImp::OnPublisherError( "
			"this : %p, "
			"code : %s, "
			"description : %s "
			")",
			this,
			code.c_str(),
			description.c_str()
			);

    JNIEnv* env;
    bool isAttachThread;
    bool bFlag = GetEnv(&env, &isAttachThread);

    if( mJniCallback != NULL ) {
        // 反射类
        jclass jniCallbackCls = env->GetObjectClass(mJniCallback);

        if( jniCallbackCls != NULL ) {
            // 发射方法
            string signure = "(Ljava/lang/String;Ljava/lang/String;)V";
            jmethodID jMethodID = env->GetMethodID(
                    jniCallbackCls,
                    "onError",
                    signure.c_str()
                    );

            jstring cCode = env->NewStringUTF(code.c_str());
            jstring cDescription = env->NewStringUTF(description.c_str());
            // 回调
            if( jMethodID ) {
                env->CallVoidMethod(mJniCallback, jMethodID, cCode, cDescription);
            }
            env->DeleteLocalRef(cCode);
            env->DeleteLocalRef(cDescription);
        }
    }

    if( bFlag ) {
        ReleaseEnv(isAttachThread);
    }
}