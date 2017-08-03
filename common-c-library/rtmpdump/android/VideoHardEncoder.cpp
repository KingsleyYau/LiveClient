//
//  VideoHardEncoder.cpp
//  RtmpClient
//
//  Created by  Max on 07/27/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  视频硬解码实现类

#include "VideoHardEncoder.h"
#include "JavaItem.h"

#include <rtmpdump/VideoFrame.h>

#include <common/CommonFunc.h>
#include <common/KThread.h>
#include <common/KLog.h>

namespace coollive {
class EncodeVideoHardRunnable : public KRunnable {
public:
	EncodeVideoHardRunnable(VideoHardEncoder *container) {
        mContainer = container;
    }
    virtual ~EncodeVideoHardRunnable() {
        mContainer = NULL;
    }
protected:
    void onRun() {
        mContainer->EncodeVideoHandle();
    }

private:
    VideoHardEncoder *mContainer;
};

VideoHardEncoder::VideoHardEncoder()
:mRuningMutex(KMutex::MutexType_Recursive) {
	FileLog("rtmpdump", "VideoHardEncoder::VideoHardEncoder( this : %p )", this);

	Init();
}

VideoHardEncoder::VideoHardEncoder(jobject jniEncoder)
:mRuningMutex(KMutex::MutexType_Recursive) {
	FileLog("rtmpdump", "VideoHardEncoder::VideoHardEncoder( this : %p, jniEncoder : %p )", this, jniEncoder);

	Init();

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	mJniEncoder = NULL;
	if( jniEncoder ) {
		mJniEncoder = env->NewGlobalRef(jniEncoder);
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

VideoHardEncoder::~VideoHardEncoder() {
	FileLog("rtmpdump", "VideoHardEncoder::~VideoHardEncoder( this : %p )", this);

	Stop();

    if( mpEncodeVideoRunnable ) {
        delete mpEncodeVideoRunnable;
        mpEncodeVideoRunnable = NULL;
    }

	JNIEnv* env;
	bool isAttachThread;

	bool bFlag = GetEnv(&env, &isAttachThread);

	if( mJniEncoder ) {
		env->DeleteGlobalRef(mJniEncoder);
		mJniEncoder = NULL;
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardEncoder::Init() {
    FileLog("rtmpdump",
    		"VideoHardEncoder::Init( "
    		"this : %p "
			")",
			this
			);

    mpCallback = NULL;

    mWidth = 480;
    mHeight = 640;
    mBitRate = 1000000;
    mKeyFrameInterval = 20;
    mFPS = 20;

    mJniEncoder = NULL;
    dataByteArray = NULL;

    mbRunning = false;
    mpEncodeVideoRunnable = new EncodeVideoHardRunnable(this);
}

void VideoHardEncoder::Stop() {
	FileLevelLog("rtmpdump",
				KLog::LOG_WARNING,
				"VideoHardEncoder::Stop( "
				"this : %p "
				")",
				this
				);

    mRuningMutex.lock();
    if( mbRunning ) {
        mbRunning = false;

        // 停止编码线程
        mEncodeVideoThread.Stop();

        VideoFrame* frame = NULL;

        // 释放空闲Buffer
        mFreeBufferList.lock();
        while( !mFreeBufferList.empty() ) {
            frame = (VideoFrame* )mFreeBufferList.front();
            mFreeBufferList.pop_front();
            if( frame != NULL ) {
                delete frame;
            } else {
                break;
            }
        }
        mFreeBufferList.unlock();
    }
    mRuningMutex.unlock();

    FileLog("rtmpdump",
            "VideoHardEncoder::Stop( "
            "[Success], "
            "this : %p "
            ")",
            this
            );
}

bool VideoHardEncoder::Create(VideoEncoderCallback* callback, int width, int height, int bitRate, int keyFrameInterval, int fps) {
    bool bFlag = true;

    FileLevelLog(
    		"rtmpdump",
			KLog::LOG_WARNING,
			"VideoHardEncoder::Create( "
    		"this : %p, "
    		"width : %d, "
    		"height : %d, "
    		"bitRate : %d, "
    		"keyFrameInterval : %d, "
    		"fps : %d "
    		" )",
			width,
			height,
			bitRate,
			keyFrameInterval,
			fps,
			this
			);

    mpCallback = callback;
    mWidth = width;
    mHeight = height;
    mKeyFrameInterval = keyFrameInterval;
    mBitRate = bitRate;
    mFPS = fps;

    Pause();
    bFlag = Reset();

    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_WARNING,
			"VideoHardEncoder::Create( "
			"[Finish], "
			"this : %p, "
			"bFlag : %s "
			")",
			this,
			bFlag?"true":"false"
			);

    return bFlag;
}

bool VideoHardEncoder::Reset() {
    FileLevelLog(
    		"rtmpdump",
			KLog::LOG_WARNING,
			"VideoHardEncoder::Reset( "
			"this : %p "
			")",
			this
			);

    // 重置编码器
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 反射类
	jclass jniEncoderCls = env->GetObjectClass(mJniEncoder);
	if( jniEncoderCls != NULL ) {
		// 发射方法
		string signure = "(IIIII)Z";
		jmethodID jMethodID = env->GetMethodID(
				jniEncoderCls,
				"reset",
				signure.c_str()
				);

		// 回调
		if( jMethodID ) {
			env->CallBooleanMethod(mJniEncoder, jMethodID, mWidth, mHeight, mKeyFrameInterval, mBitRate, mFPS);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

    return true;
}

void VideoHardEncoder::Pause() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"VideoHardDecoder::Pause( "
			"this : %p "
			")",
			this
			);

    // 暂停编码器
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

	// 反射类
	jclass jniEncoderCls = env->GetObjectClass(mJniEncoder);
	if( jniEncoderCls != NULL ) {
		// 发射方法
		string signure = "()V";
		jmethodID jMethodID = env->GetMethodID(
				jniEncoderCls,
				"pause",
				signure.c_str()
				);

		// 回调
		if( jMethodID ) {
			env->CallVoidMethod(mJniEncoder, jMethodID);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardEncoder::EncodeVideoFrame(void* data, int size, void* frame) {
	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoFrame( "
			"size : %d "
			")",
			size
			);

    // 编码视频
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
	jclass jniEncoderCls = env->GetObjectClass(mJniEncoder);
	if( jniEncoderCls != NULL ) {
		// 发射方法
		string signure = "([BI)Z";
		jmethodID jMethodID = env->GetMethodID(
				jniEncoderCls,
				"encodeVideoFrame",
				signure.c_str()
				);

		// 回调
		if( jMethodID ) {
			env->CallBooleanMethod(mJniEncoder, jMethodID, dataByteArray, size);
		}
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoFrame( "
			"[Success], "
			"size : %d "
			")",
			size
			);
}

void VideoHardEncoder::EncodeVideoHandle() {
	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoHandle( "
			"[Start], "
			"this : %p, "
			"mJniEncoder : %p "
			")",
			this,
			mJniEncoder
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

    while ( mbRunning ) {
		if( mJniEncoder ) {
			// 反射类
			jclass jniEncoderCls = env->GetObjectClass(mJniEncoder);
			if( jniEncoderCls != NULL ) {
				// 反射方法
				string signure = "()L" LS_VIDEO_ITEM_CLASS;
				jmethodID jMethodID = env->GetMethodID(
						jniEncoderCls,
						"getEncodeVideoFrame",
						signure.c_str()
						);

				if( jMethodID ) {
					jobject jVideoFrame = env->CallObjectMethod(mJniEncoder, jMethodID);
					if( jVideoFrame ) {
						HandleVideoFrame(env, jniEncoderCls, jVideoFrame);

						env->DeleteLocalRef(jVideoFrame);
					}
				}

				env->DeleteLocalRef(jniEncoderCls);
			}
		}

		Sleep(1);
    }


	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoHandle( "
			"[Exit], "
			"this : %p, "
			"mJniEncoder : %p "
			")",
			this,
			mJniEncoder
			);
}

void VideoHardEncoder::HandleVideoFrame(JNIEnv* env, jclass jniEncoderCls, jobject jVideoFrame) {
	int bufferIndex = -1;
	int timestamp = 0;
	int size = 0;
	int width = 0;
	int height = 0;

	jclass jniVideoFrameCls = env->GetObjectClass(jVideoFrame);
	if( jniVideoFrameCls != NULL ) {
		jfieldID jfBufferIndex = env->GetFieldID(jniVideoFrameCls, "bufferIndex", "I");
		bufferIndex = env->GetIntField(jVideoFrame, jfBufferIndex);

		jfieldID jfTimestamp = env->GetFieldID(jniVideoFrameCls, "timestamp", "I");
		timestamp = env->GetIntField(jVideoFrame, jfTimestamp);

		jfieldID jfSize = env->GetFieldID(jniVideoFrameCls, "size", "I");
		size = env->GetIntField(jVideoFrame, jfSize);

		jfieldID jfWidth = env->GetFieldID(jniVideoFrameCls, "width", "I");
		width = env->GetIntField(jVideoFrame, jfWidth);

		jfieldID jfHeight = env->GetFieldID(jniVideoFrameCls, "height", "I");
		height = env->GetIntField(jVideoFrame, jfHeight);

		if( bufferIndex != -1 ) {
			FileLog("rtmpdump",
					"VideoHardEncoder::EncodeVideoHandle( "
					"[Get Encoded Video Frame], "
					"bufferIndex : %d, "
					"timestamp : %d, "
					"size : %d, "
					"width : %d, "
					"height : %d "
					")",
					bufferIndex,
					timestamp,
					size,
					width,
					height
					);

			jfieldID jfData = env->GetFieldID(jniVideoFrameCls, "data", "[B");
			jbyteArray jByteArray = (jbyteArray)env->GetObjectField(jVideoFrame, jfData);
			jbyte* data = env->GetByteArrayElements(jByteArray, 0);

			if( mpCallback ) {
				// 回调编码成功
				mpCallback->OnEncodeVideoFrame(this, (char*)data, size, timestamp);
			}

			env->ReleaseByteArrayElements(jByteArray, data, 0);
			env->DeleteLocalRef(jByteArray);

			// 反射方法
			string signure = "(I)V";
			jmethodID jMethodID = env->GetMethodID(
					jniEncoderCls,
					"releaseVideoFrame",
					signure.c_str()
					);

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniEncoder, jMethodID, bufferIndex);
			}
		}

		env->DeleteLocalRef(jniVideoFrameCls);
	}
}
}
