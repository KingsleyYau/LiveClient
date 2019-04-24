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

		string signure = "";
		jmethodID jMethodID = 0;

		// 重置编码器
		signure = "()Z";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"reset",
				signure.c_str()
				);
		mJniDecoderResetMethodID = jMethodID;

		// 暂停编码器
		signure = "()V";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"pause",
				signure.c_str()
				);
		mJniDecoderPauseMethodID = jMethodID;

		// 获取解码视频帧
		signure = "()L" LS_DECODE_VIDEO_ITEM_CLASS ";";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"getDecodeVideoFrame",
				signure.c_str()
				);
		mJniDecoderGetDecodeVideoMethodID = jMethodID;

		signure = "([BI[BII)Z";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"decodeVideoKeyFrame",
				signure.c_str()
				);
		mJniDecoderDecodeKeyMethodID = jMethodID;

		signure = "([BII)Z";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"decodeVideoFrame",
				signure.c_str()
				);
		mJniDecoderDecodeVideoMethodID = jMethodID;

		signure = "(L" LS_DECODE_VIDEO_ITEM_CLASS ";)V";
		jMethodID = env->GetMethodID(
				jniDecoderCls,
				"releaseVideoFrame",
				signure.c_str()
				);
		mJniDecoderReleaseMethodID = jMethodID;

		// 解码帧Java引用
		jobject jVideoFrameItem;
		InitClassHelper(env, LS_DECODE_VIDEO_ITEM_CLASS, &jVideoFrameItem);
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
}

bool VideoHardDecoder::Create(VideoDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoHardDecoder::Create( this : %p )", this);

    bool bFlag = true;

    mpCallback = callback;

    FileLevelLog("rtmpdump",
    		KLog::LOG_WARNING,
    		"VideoHardDecoder::Create( "
    		"this : %p, "
			"[%s] "
    		")",
			this,
			bFlag?"Success":"Fail"
			);

    return bFlag;
}

bool VideoHardDecoder::Reset() {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "VideoHardDecoder::Reset( "
                "this : %p "
                ")",
                this
                );

    bool bFlag = false;

	JNIEnv* env;
	bool isAttachThread;
	bool bAttatch = GetEnv(&env, &isAttachThread);

	if( mJniDecoder && mJniDecoderResetMethodID ) {
		bFlag = env->CallBooleanMethod(mJniDecoder, mJniDecoderResetMethodID);
	}

	if( bAttatch ) {
		ReleaseEnv(isAttachThread);
	}

	if( bFlag ) {
		bFlag = Start();
	}

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

	JNIEnv* env;
	bool isAttachThread;
	bool bAttatch = GetEnv(&env, &isAttachThread);

	if( mJniDecoder && mJniDecoderPauseMethodID ) {
		env->CallVoidMethod(mJniDecoder, mJniDecoderPauseMethodID);
	}

	if( bAttatch ) {
		ReleaseEnv(isAttachThread);
	}
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

    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
        mSpSize = 0;
    }

    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
        mPpsSize = 0;
    }

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
    mNaluHeaderSize = 0;

    mJniDecoder = NULL;
    spsByteArray = NULL;
    ppsByteArray = NULL;
    dataByteArray = NULL;

    mbRunning = false;
    mpDecodeVideoRunnable = new DecodeVideoHardRunnable(this);
}

void VideoHardDecoder::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int naluHeaderSize) {
	FileLog("rtmpdump",
			"VideoHardDecoder::DecodeVideoKeyFrame( "
			"this : %p, "
			"sps_size : %d, "
			"pps_size : %d, "
			"naluHeaderSize : %d "
			")",
			this,
			sps_size,
			pps_size,
			naluHeaderSize
			);

	bool bChange = true;

//	if( mSpSize != sps_size || memcmp(mpSps, sps, sps_size) != 0 ) {
//		bChange = true;
//	} else if( mPpsSize != pps_size || memcmp(mpPps, pps, pps_size) != 0 ) {
//		bChange = true;
//	}

	if( bChange ) {
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

		mNaluHeaderSize = naluHeaderSize;

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

		if( mJniDecoder && mJniDecoderDecodeKeyMethodID ) {
			env->CallBooleanMethod(mJniDecoder, mJniDecoderDecodeKeyMethodID, spsByteArray, mSpSize, ppsByteArray, mPpsSize, mNaluHeaderSize);
		}

		if( bFlag ) {
			ReleaseEnv(isAttachThread);
		}
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

	bool bDecode = false;
    // Mux
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bool bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if( bFlag && naluArraySize > 0 ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_STAT,
                     "VideoHardDecoder::DecodeVideoFrame( "
					 "this : %p, "
                     "[Got Nalu Array], "
                     "timestamp : %u, "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
					 this,
                     timestamp,
                     size,
                     naluArraySize
                     );

        mVideoFrame.ResetFrame();

        int naluIndex = 0;
        while( naluIndex < naluArraySize ) {
            Nalu* nalu = naluArray + naluIndex;
            naluIndex++;

            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoHardDecoder::DecodeVideoFrame( "
						 "this : %p, "
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
						 this,
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType()
                         );

            mVideoFrame.AddBuffer(sync_bytes, sizeof(sync_bytes));
            mVideoFrame.AddBuffer((const unsigned char*)nalu->GetNaluBody(), nalu->GetNaluBodySize());
        }

        bDecode = true;
    }

    if( bDecode ) {
    	JNIEnv* env;
    	bool isAttachThread;
    	bool bFlag = GetEnv(&env, &isAttachThread);
    	int newSize = mVideoFrame.mBufferLen;

    	// 创建新DataBuffer
    	if( dataByteArray != NULL ) {
    		int oldLen = env->GetArrayLength(dataByteArray);
    		if( oldLen < newSize ) {
    			env->DeleteGlobalRef(dataByteArray);
    			dataByteArray = NULL;
    		}
    	}

    	if( dataByteArray == NULL ) {
    		jbyteArray localDataByteArray = env->NewByteArray(newSize);
    		dataByteArray = (jbyteArray)env->NewGlobalRef(localDataByteArray);
    		env->DeleteLocalRef(localDataByteArray);
    	}

    	if( dataByteArray != NULL ) {
    		env->SetByteArrayRegion(dataByteArray, 0, newSize, (const jbyte*)mVideoFrame.GetBuffer());
    	}

    	// 反射类
    	if( mJniDecoder && mJniDecoderDecodeVideoMethodID ) {
    		env->CallBooleanMethod(mJniDecoder, mJniDecoderDecodeVideoMethodID, dataByteArray, newSize, timestamp);
    	}

    	if( bFlag ) {
    		ReleaseEnv(isAttachThread);
    	}
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
	if( mJniDecoder && mJniDecoderReleaseMethodID ) {
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
    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_MSG,
			"VideoHardDecoder::StartDropFrame( "
			"this : %p "
			")",
			this
			);
}

void VideoHardDecoder::ClearVideoFrame() {
    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_MSG,
			"VideoHardDecoder::ClearVideoFrame( "
			"this : %p "
			")",
			this
			);
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
			if( mJniDecoderGetDecodeVideoMethodID ) {
				jobject jVideoFrame = env->CallObjectMethod(mJniDecoder, mJniDecoderGetDecodeVideoMethodID);
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
