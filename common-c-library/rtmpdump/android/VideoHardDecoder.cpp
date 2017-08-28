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
		mJniDecoder = env->NewGlobalRef(jniDecoder);
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

bool VideoHardDecoder::Create(VideoDecoderCallback* callback)
{
	FileLog("rtmpdump", "VideoHardDecoder::Create( this : %p )", this);
    bool result = false;
    if (NULL != callback) {
        mpCallback = callback;
        result = true;
    }

    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }

    // 创建解码器
	mbRunning = true;

	// 开启解码线程
	mDecodeVideoThread.Start(mpDecodeVideoRunnable);

    mRuningMutex.unlock();

    FileLog("rtmpdump", "VideoHardDecoder::Create( "
    		"[Success], "
    		"this : %p "
    		")",
			this
			);

    return result;
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

void VideoHardDecoder::Stop() {
    FileLog("rtmpdump",
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
            "VideoHardDecoder::Stop( "
            "[Success], "
            "this : %p "
            ")",
            this
            );
}

bool VideoHardDecoder::Reset() {
    FileLog("rtmpdump",
            "VideoHardDecoder::Reset( "
            "this : %p "
            ")",
            this
            );
	bool bFlag = true;
	return bFlag;
}

void VideoHardDecoder::Pause() {
    FileLog("rtmpdump",
            "VideoHardDecoder::Pause( "
            "this : %p "
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

void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoKeyFrame( "
			"sps_size : %d, "
			"pps_size : %d "
			")",
			sps_size,
			pps_size
			);

	bool bChange = false;

    // 重新设置解码器变量
    if( mSpSize != sps_size ) {
        mSpSize = sps_size;
        if( mpSps ) {
            delete[] mpSps;
            mpSps = NULL;
        }
        mpSps = new char[mSpSize];
        memcpy(mpSps, sps, mSpSize);

        bChange = true;
    }
    
    if( mPpsSize != pps_size ) {
        mPpsSize = pps_size;
        if( mpPps ) {
            delete[] mpPps;
            mpPps = NULL;
        }
        mpPps = new char[mPpsSize];
        memcpy(mpPps, pps, mPpsSize);

        bChange = true;
    }

    mNalUnitHeaderLength = nalUnitHeaderLength;

    // 解码视频
	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

    if( bChange ) {
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
	}

	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}
}

void VideoHardDecoder::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoFrame( "
			"timestamp : %d "
			")",
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
	VideoFrame* videoFrame = (VideoFrame *)frame;

	FileLog("rtmpdump",
			"VideoHardDecoder::ReleaseVideoFrame( "
			"frame : %p, "
			"timestamp : %u "
			")",
			frame,
			videoFrame->mTimestamp
			);

	ReleaseBuffer(videoFrame);
}

void VideoHardDecoder::ReleaseBuffer(VideoFrame* videoFrame) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(videoFrame);
	mFreeBufferList.unlock();
}

void VideoHardDecoder::StartDropFrame() {

}

void VideoHardDecoder::SetRecordFilePath(const string& recordH264FilePath) {


}
void VideoHardDecoder::DecodeVideoHandle() {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoHandle( "
			"[Start], "
			"this : %p, "
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
			// 反射类
			jclass jniDecoderCls = env->GetObjectClass(mJniDecoder);
			if( jniDecoderCls != NULL ) {
				// 反射方法
				string signure = "()L" LS_VIDEO_ITEM_CLASS;
				jmethodID jMethodID = env->GetMethodID(
						jniDecoderCls,
						"getDecodeVideoFrame",
						signure.c_str()
						);

				if( jMethodID ) {
					jobject jVideoFrame = env->CallObjectMethod(mJniDecoder, jMethodID);
					if( jVideoFrame ) {
						HandleVideoFrame(env, jniDecoderCls, jVideoFrame);

						env->DeleteLocalRef(jVideoFrame);
					}
				}

				env->DeleteLocalRef(jniDecoderCls);
			}
		}

		Sleep(1);
    }


	if( bFlag ) {
		ReleaseEnv(isAttachThread);
	}

	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoHandle( "
			"[Exit], "
			"this : %p, "
			"mJniDecoder : %p "
			")",
			this,
			mJniDecoder
			);
}

void VideoHardDecoder::HandleVideoFrame(JNIEnv* env, jclass jniDecoderCls, jobject jVideoFrame) {
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
					"VideoHardDecoder::DecodeVideoHandle( "
					"[Get Decoded Video Frame], "
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

			mFreeBufferList.lock();
			VideoFrame* videoFrame = NULL;
			if( !mFreeBufferList.empty() ) {
				videoFrame = (VideoFrame *)mFreeBufferList.front();
				mFreeBufferList.pop_front();

			} else {
				videoFrame = new VideoFrame();
			}
			mFreeBufferList.unlock();

		    // 更新数据格式
			videoFrame->ResetFrame();
		    videoFrame->mTimestamp = timestamp;
		    videoFrame->mWidth = width;
		    videoFrame->mHeight = height;
		    videoFrame->SetBuffer((const unsigned char*)data, size);

			if( mpCallback ) {
				// 回调播放
				mpCallback->OnDecodeVideoFrame(this, videoFrame, timestamp);
			} else {
				ReleaseVideoFrame(videoFrame);
			}

			env->ReleaseByteArrayElements(jByteArray, data, 0);
			env->DeleteLocalRef(jByteArray);

			// 反射方法
			string signure = "(I)V";
			jmethodID jMethodID = env->GetMethodID(
					jniDecoderCls,
					"releaseVideoFrame",
					signure.c_str()
					);

			// 回调
			if( jMethodID ) {
				env->CallVoidMethod(mJniDecoder, jMethodID, bufferIndex);
			}
		}

		env->DeleteLocalRef(jniVideoFrameCls);
	}
}
}
