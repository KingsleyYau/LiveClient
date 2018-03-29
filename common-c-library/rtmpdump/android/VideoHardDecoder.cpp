//
//  VideoHardDecoder.cpp
//  RtmpClient
//
//  Created by  Max on 05/06/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//

#include "VideoHardDecoder.h"
#include "JavaItem.h"

#include <common/CommonFunc.h>
#include <common/KThread.h>
#include <common/KLog.h>

namespace coollive {

class DecodeVideoHardRunnable : public KRunnable {
public:
	DecodeVideoHardRunnable(VideoHardDecoder *container) {
        mContainer = container;
    }
    virtual ~DecodeVideoHardRunnable() {
        mContainer = NULL;
    }
protected:
    void onRun() {
        mContainer->DecodeVideoHandle();
    }

private:
    VideoHardDecoder *mContainer;
};

VideoHardDecoder::VideoHardDecoder()
:mRuningMutex(KMutex::MutexType_Recursive) {
	FileLog("rtmpdump", "VideoHardDecoder::VideoHardDecoder( this : %p )", this);

	Init();
}

VideoHardDecoder::VideoHardDecoder(jobject jniDecoder)
:mRuningMutex(KMutex::MutexType_Recursive) {
	FileLog("rtmpdump", "VideoHardDecoder::VideoHardDecoder( this : %p, jniDecoder : %p )", this, jniDecoder);

	Init();

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniDecoder = NULL;
	if( jniDecoder ) {
		// 解码器Java引用
		mJniDecoder = env->NewGlobalRef(jniDecoder);
		jclass jniDecoderCls = env->GetObjectClass(mJniDecoder);
		// 反射方法
		string signure = "()L" LS_VIDEO_ITEM_CLASS ";";
		jmethodID jMethodID = env->GetMethodID(
				jniDecoderCls,
				"getDecodeVideoFrame",
				signure.c_str()
				);
		mJniDecoderMethodID = jMethodID;

		signure = "(L" LS_VIDEO_ITEM_CLASS ";)V";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"releaseVideoFrame",
				signure.c_str()
				);
		mJniDecoderReleaseMethodID = jMethodID;

		// 解码帧Java引用
		jobject jVideoFrameItem;
		InitClassHelper(env, LS_VIDEO_ITEM_CLASS, &jVideoFrameItem);
		jclass jniVideoFrameCls = env->GetObjectClass(jVideoFrameItem);
		env->DeleteGlobalRef(jVideoFrameItem);
		mJniVideoFrameTimestampMethodID = env->GetFieldID(jniVideoFrameCls, "timestamp", "I");
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

VideoHardDecoder::~VideoHardDecoder() {
	FileLog("rtmpdump", "VideoHardDecoder::~VideoHardDecoder( this : %p )", this);

	Stop();

    if( mpDecodeVideoRunnable ) {
        delete mpDecodeVideoRunnable;
        mpDecodeVideoRunnable = NULL;
    }

	JNIEnv* env;
	bool isAttachThread;

	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniDecoder ) {
		env->DeleteGlobalRef(mJniDecoder);
		mJniDecoder = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
    
    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
    }
    
    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
    }
}

bool VideoHardDecoder::Create(VideoDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::Create( this : %p )", this);

    bool result = true;

    mpCallback = callback;

    FileLevelLog("rtmpdump",
    		KLog::LOG_WARNING,
    		"VideoHardDecoder::Create( "
    		"this : %p, "
    		"[Success] "
    		")",
			this
			);

    return result;
}

bool VideoHardDecoder::Reset() {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "VideoHardDecoder::Reset( "
                "this : %p "
                ")",
                this
                );

	bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoHardDecoder::Reset( "
				 "this : %p, "
                 "[%s] "
                 ")",
				 this,
                 bFlag?"Success":"Fail"
                 );

	return bFlag;
}

void VideoHardDecoder::Pause() {
	FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoHardDecoder::Pause( "
                "this : %p "
                ")",
                this
                );

	Stop();
}

bool VideoHardDecoder::Start() {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::Start( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }

    mbRunning = true;

	// 开启解码线程
	mDecodeVideoThread.Start(mpDecodeVideoRunnable);

	bFlag = true;

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::Start( "
				 "this : %p, "
                 "[%s] "
                 ")",
				 this,
                 bFlag?"Success":"Fail"
                 );

    return bFlag;
}

void VideoHardDecoder::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::Stop( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        mbRunning = false;

        // 停止解码线程
        mDecodeVideoThread.Stop();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardDecoder::Stop( "
                 "this : %p, "
				 "[Success] "
                 ")",
                 this
                 );
}

void VideoHardDecoder::ResetStream() {
    FileLog("rtmpdump",
            "VideoHardDecoder::ResetStream( "
            "this : %p "
            ")",
            this
            );
}

void VideoHardDecoder::Init() {
    FileLog("rtmpdump",
            "VideoHardDecoder::Init( "
            "this : %p "
            ")",
            this
            );

    mpCallback = NULL;

    mpSps = NULL;
    mSpSize = 0;
    mpPps = NULL;
    mPpsSize = 0;
    mNalUnitHeaderLength = 0;

    mJniDecoder = NULL;
    spsByteArray = NULL;
    ppsByteArray = NULL;
    dataByteArray = NULL;

    mbRunning = false;
    mpDecodeVideoRunnable = new DecodeVideoHardRunnable(this);
}

void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoKeyFrame( "
			"this : %p, "
			"sps_size : %d, "
			"pps_size : %d, "
			"nalUnitHeaderLength : %d "
			")",
			this,
			sps_size,
			pps_size,
			nalUnitHeaderLength
			);

    // 重新设置解码器变量
	mSpSize = sps_size;
	if( mpSps ) {
		delete[] mpSps;
		mpSps = NULL;
	}
	mpSps = new char[mSpSize];
	memcpy(mpSps, sps, mSpSize);

	mPpsSize = pps_size;
	if( mpPps ) {
		delete[] mpPps;
		mpPps = NULL;
	}
	mpPps = new char[mPpsSize];
	memcpy(mpPps, pps, mPpsSize);

    mNalUnitHeaderLength = nalUnitHeaderLength;

    // 解码视频
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

		// 创建新SPS
		if( spsByteArray != NULL ) {
			int oldLen = env->GetArrayLength(spsByteArray);
			if( oldLen < mSpSize ) {
				env->DeleteGlobalRef(spsByteArray);
				spsByteArray = NULL;
			}
		}

		if( spsByteArray == NULL ) {
			jbyteArray localDataByteArray = env->NewByteArray(mSpSize);
			spsByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
			env->DeleteLocalRef(localDataByteArray);
		}

		if( spsByteArray != NULL ) {
			env->SetByteArrayRegion(spsByteArray, 0, mSpSize, (const jbyte*)mpSps);
		}

		// 创建新PPS
		if( ppsByteArray != NULL ) {
			int oldLen = env->GetArrayLength(ppsByteArray);
			if( oldLen < mPpsSize ) {
				env->DeleteGlobalRef(ppsByteArray);
				ppsByteArray = NULL;
			}
		}

		if( ppsByteArray == NULL ) {
			jbyteArray localDataByteArray = env->NewByteArray(mPpsSize);
			ppsByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
			env->DeleteLocalRef(localDataByteArray);
		}

		if( ppsByteArray != NULL ) {
			env->SetByteArrayRegion(ppsByteArray, 0, mPpsSize, (const jbyte*)mpPps);
		}

	// 反射类
	jclass jniDecoderCls = env->GetObjectClass(mJniDecoder);
	if( jniDecoderCls != NULL ) {
		// 反射方法
		string signure = "([BI[BII)Z";
		jmethodID jMethodID = env->GetMethodID(
				jniDecoderCls,
				"decodeVideoKeyFrame",
				signure.c_str()
				);

		// 回调
		if( jMethodID ) {
			env->CallBooleanMethod(mJniDecoder, jMethodID, spsByteArray, mSpSize, ppsByteArray, mPpsSize, mNalUnitHeaderLength);
		}

		env->DeleteLocalRef(jniDecoderCls);
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardDecoder::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoFrame( "
			"size : %d, "
			"timestamp : %d "
			")",
			size,
			timestamp
			);

	void* frame = NULL;

    // 解码视频
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 创建新DataBuffer
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

	// 反射类
	jclass jniDecoderCls = env->GetObjectClass(mJniDecoder);
	if( jniDecoderCls != NULL ) {
		// 发射方法
		string signure = "([BII)Z";
		jmethodID jMethodID = env->GetMethodID(
				jniDecoderCls,
				"decodeVideoFrame",
				signure.c_str()
				);

		// 回调
		if( jMethodID ) {
			env->CallBooleanMethod(mJniDecoder, jMethodID, dataByteArray, size, timestamp);
		}

		env->DeleteLocalRef(jniDecoderCls);
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoFrame( "
			"[Success], "
			"timestamp : %d "
			")",
			timestamp
			);
}

void VideoHardDecoder::ReleaseVideoFrame(void* frame) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_STAT,
			"VideoHardDecoder::ReleaseVideoFrame( "
			"frame : %p "
			")",
			frame
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 减少JNI引用
	jobject jVideoFrame = (jobject)frame;

	// 反射类
	if( mJniDecoder ) {
		// 回调
		if( mJniDecoderReleaseMethodID ) {
			env->CallVoidMethod(mJniDecoder, mJniDecoderReleaseMethodID, jVideoFrame);
		}
	}

	env->DeleteGlobalRef(jVideoFrame);

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardDecoder::StartDropFrame() {

}

void VideoHardDecoder::DecodeVideoHandle() {
    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_MSG,
			"VideoHardDecoder::DecodeVideoHandle( "
			"this : %p, "
			"[Start], "
			"mJniDecoder : %p "
			")",
			this,
			mJniDecoder
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

    while ( mbRunning ) {
		if( mJniDecoder ) {
			if( mJniDecoderMethodID ) {
				jobject jVideoFrame = env->CallObjectMethod(mJniDecoder, mJniDecoderMethodID);
				if( jVideoFrame ) {
					int timestamp = env->GetIntField(jVideoFrame, mJniVideoFrameTimestampMethodID);

					FileLevelLog(
							"rtmpdump",
							KLog::LOG_STAT,
							"VideoHardDecoder::DecodeVideoHandle( "
							"this : %p, "
							"[Get decode frame], "
							"jVideoFrame : %p, "
							"timestamp : %d "
							")",
							this,
							jVideoFrame,
							timestamp
							);

					if( mpCallback ) {
						// 增加JNI引用
						jobject jNewVideoFrame = env->NewGlobalRef(jVideoFrame);
						// 回调解码成功
						mpCallback->OnDecodeVideoFrame(this, jNewVideoFrame, timestamp);
					}

					env->DeleteLocalRef(jVideoFrame);
				}
			}
		}

		Sleep(10);
    }

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_MSG,
			"VideoHardDecoder::DecodeVideoHandle( "
			"this : %p, "
			"[Exit], "
			"mJniDecoder : %p "
			")",
			this,
			mJniDecoder
			);
}

}
