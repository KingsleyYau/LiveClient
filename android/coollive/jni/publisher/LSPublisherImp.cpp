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
:mVideoRotateFilter(fps), mPublisherMutex(KMutex::MutexType_Recursive)
{
	// TODO Auto-generated constructor stub
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "LSPublisherImp::LSPublisherImp( this : %p )", this);

    // 视频参数
    mWidth = width;
    mHeight = height;
    mBitRate = bitRate;
    mKeyFrameInterval = keyFrameInterval;
    mFPS = fps;

    mVideoFrameLastPushTime = 0;
    mVideoFrameStartPushTime = 0;
    mVideoFrameIndex = 0;
	mVideoFrameInterval = 8;
	if( fps > 0 ) {
		mVideoFrameInterval = 1000.0 / fps;
	}

    mVideoPause = false;
    mVideoResume = true;
    mVideoFramePauseTime = 0;

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

	mPublisher.SetStatusCallback(this);
	mPublisher.SetVideoParam(width, height);
//	mPublisher.SetAudioParam(44100, 1, 16);

//	// 滤镜
//	mVideoFilters.SetFiltersCallback(this);
//	// 增加旋转滤镜
//	mVideoFilters.AddFilter(&mVideoRotateFilter);
//	// 预览格式
//	mVideoFormatConverter.SetDstFormat(VIDEO_FORMATE_RGB565);

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

    // 复位帧率控制
    mVideoFrameStartPushTime = 0;
    mVideoFrameIndex = 0;
    mVideoFramePauseTime = 0;
    mVideoFrameLastPushTime = 0;

    mPublisherMutex.lock();
	mVideoResume = true;
	mPublisherMutex.unlock();
}

void LSPublisherImp::SetUseHardEncoder(bool useHardEncoder) {
	if( mUseHardEncoder != useHardEncoder ) {
		DestroyEncoders();

		mUseHardEncoder = useHardEncoder;

		CreateEncoders();
	}
}

void LSPublisherImp::PushVideoFrame(void* data, int size, int width, int height) {
	mPublisherMutex.lock();
    // 视频是否暂停录制
    if( !mVideoPause ) {
        long long now = getCurrentTime();

        // 视频是否恢复
        if( !mVideoResume ) {
            // 视频未恢复
            mVideoResume = true;
            // 更新上次暂停导致的时间差
            long long videoFrameDiffTime = now - mVideoFrameLastPushTime;
            videoFrameDiffTime -= mVideoFrameInterval;
        	FileLevelLog(
        			"rtmpdump",
        			KLog::LOG_WARNING,
        			"LSPublisherImp::PushVideoFrame( "
        			"[Video capture is resume], "
        			"this : %p, "
        			"videoFrameDiffTime : %lld "
        			")",
        			this,
					videoFrameDiffTime
        			);
        	mPublisher.AddVideoTimestamp((unsigned int)videoFrameDiffTime);
            mVideoFramePauseTime += videoFrameDiffTime;
        }

        // 控制帧率
        if( mVideoFrameStartPushTime == 0 ) {
            mVideoFrameStartPushTime = now;
        }
        long long diffTime = now - mVideoFrameStartPushTime;
        diffTime -= mVideoFramePauseTime;
        long long videoFrameInterval = diffTime - (mVideoFrameIndex * mVideoFrameInterval);

        if( videoFrameInterval >= 0 ) {
            // 放到过滤器
//        	mVideoFilters.FilterFrame(data, size, width, height, VIDEO_FORMATE_NV21);
        	// 放到推流器
        	mPublisher.PushVideoFrame(data, size, NULL);

            // 更新最后处理帧数目
            mVideoFrameIndex++;
            // 更新最后处理时间
            mVideoFrameLastPushTime = now;
        }
    } else {
    	FileLevelLog(
    			"rtmpdump",
    			KLog::LOG_MSG,
				"LSPublisherImp::PushVideoFrame( "
				"[Video capture is pausing], "
				"this : %p "
				")",
				this
				);
    }
    mPublisherMutex.unlock();
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
	mPublisherMutex.lock();
    mVideoPause = true;
    mVideoResume = false;
	mPublisherMutex.unlock();
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
	mPublisherMutex.lock();
    mVideoPause = false;
	mPublisherMutex.unlock();
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
//	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_NV21);
//	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_RGB565);
	mpVideoEncoder->Create(mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS, VIDEO_FORMATE_RGBA);
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
