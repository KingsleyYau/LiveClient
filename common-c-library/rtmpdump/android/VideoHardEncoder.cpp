//
//  VideoHardEncoder.cpp
//  RtmpClient
//
//  Created by  Max on 07/27/2017.
//  Copyright © 2017 net.qdating. All rights reserved.
//  视频硬解码实现类

#include "VideoHardEncoder.h"

#include <rtmpdump/video/VideoFrame.h>

#include "JavaItem.h"

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
		// 编码器Java引用
		mJniEncoder = env->NewGlobalRef(jniEncoder);
		jclass jniEncoderCls = env->GetObjectClass(mJniEncoder);

		string signure = "";
		jmethodID jMethodID = 0;

		// 重置编码器
		signure = "(IIIII)Z";
		jMethodID = env->GetMethodID(
				jniEncoderCls,
				"reset",
				signure.c_str()
				);
		mJniEncoderResetMethodID = jMethodID;

		// 暂停编码器
		signure = "()V";
		jMethodID = env->GetMethodID(
				jniEncoderCls,
				"pause",
				signure.c_str()
				);
		mJniEncoderPauseMethodID = jMethodID;

		// 获取编码视频帧
		signure = "()L" LS_ENCODE_VIDEO_ITEM_CLASS ";";
		jMethodID = env->GetMethodID(
				jniEncoderCls,
				"getEncodeVideoFrame",
				signure.c_str()
				);
		mJniEncoderGetEncodeVideoMethodID = jMethodID;

		// 编码视频帧
		signure = "([BI)Z";
		jMethodID = env->GetMethodID(
				jniEncoderCls,
				"encodeVideoFrame",
				signure.c_str()
				);
		mJniEncoderEncodeVideoMethodID = jMethodID;

		// 释放视频帧
		signure = "(L" LS_ENCODE_VIDEO_ITEM_CLASS ";)V";
		jMethodID = env->GetMethodID(
				jniEncoderCls,
				"releaseVideoFrame",
				signure.c_str()
				);
		mJniEncoderReleaseMethodID = jMethodID;

		// 编码帧Java引用
		jobject jVideoFrameItem;
		InitClassHelper(env, LS_ENCODE_VIDEO_ITEM_CLASS, &jVideoFrameItem);
		jclass jniVideoFrameCls = env->GetObjectClass(jVideoFrameItem);
		env->DeleteGlobalRef(jVideoFrameItem);
		mJniVideoFrameTimestampMethodID = env->GetFieldID(jniVideoFrameCls, "timestamp", "I");
		mJniVideoFrameDataMethodID = env->GetFieldID(jniVideoFrameCls, "data", "[B");
		mJniVideoFrameSizeMethodID = env->GetFieldID(jniVideoFrameCls, "size", "I");
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

	if( dataByteArray ) {
		env->DeleteGlobalRef(dataByteArray);
		dataByteArray = NULL;
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
    mJniEncoderResetMethodID = 0;
    mJniEncoderPauseMethodID = 0;
    mJniEncoderGetEncodeVideoMethodID = 0;
    mJniEncoderEncodeVideoMethodID = 0;
    mJniEncoderReleaseMethodID = 0;

    mJniVideoFrameTimestampMethodID = 0;
    mJniVideoFrameDataMethodID = 0;
    mJniVideoFrameSizeMethodID = 0;

    mbRunning = false;
    mpEncodeVideoRunnable = new EncodeVideoHardRunnable(this);
}

bool VideoHardEncoder::Create(int width, int height, int bitRate, int keyFrameInterval, int fps, VIDEO_FORMATE_TYPE type) {
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
			this,
			width,
			height,
			bitRate,
			keyFrameInterval,
			fps
			);

    mWidth = width;
    mHeight = height;
    mKeyFrameInterval = keyFrameInterval;
    mBitRate = bitRate;
    mFPS = fps;

    FileLevelLog(
    		"rtmpdump",
    		KLog::LOG_WARNING,
			"VideoHardEncoder::Create( "
			"this : %p, "
			"[%s] "
			")",
			this,
			bFlag?"Success":"Fail"
			);

    return bFlag;
}

void VideoHardEncoder::SetCallback(VideoEncoderCallback* callback) {
	mpCallback = callback;
}

bool VideoHardEncoder::Reset() {
    FileLevelLog(
    		"rtmpdump",
			KLog::LOG_MSG,
			"VideoHardEncoder::Reset( "
			"this : %p "
			")",
			this
			);

    bool bFlag = false;

	JNIEnv* env;
	bool isAttachThread;
	bool bAttatch = GetEnv(&env, &isAttachThread);

	if( mJniEncoder && mJniEncoderResetMethodID ) {
		bFlag = env->CallBooleanMethod(mJniEncoder, mJniEncoderResetMethodID, mWidth, mHeight, mBitRate, mKeyFrameInterval, mFPS);
	}

	if( bAttatch ) {
		ReleaseEnv(isAttachThread);
	}

	if( bFlag ) {
		bFlag = Start();
	}

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoEncoderH264::Reset( "
                 "[%s], "
                 "this : %p "
                 ")",
				 bFlag?"Success":"Fail",
                 this
                 );

    return bFlag;
}

void VideoHardEncoder::Pause() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"VideoHardEncoder::Pause( "
			"this : %p "
			")",
			this
			);

	Stop();

	JNIEnv* env;
	bool isAttachThread;
	bool bAttatch = GetEnv(&env, &isAttachThread);

	if( mJniEncoder && mJniEncoderPauseMethodID ) {
		env->CallVoidMethod(mJniEncoder, mJniEncoderPauseMethodID);
	}

	if( bAttatch ) {
		ReleaseEnv(isAttachThread);
	}

}

bool VideoHardEncoder::Start() {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardEncoder::Start( "
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
    mEncodeVideoThread.Start(mpEncodeVideoRunnable);

	bFlag = true;

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardEncoder::Start( "
				 "this : %p, "
                 "[%s] "
                 ")",
				 this,
                 bFlag?"Success":"Fail"
                 );

    return bFlag;
}

void VideoHardEncoder::Stop() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_MSG,
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
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoHardEncoder::Stop( "
                 "this : %p, "
				 "[Success] "
                 ")",
                 this
                 );
}

VideoFrameRateType VideoHardEncoder::EncodeVideoFrame(void* data, int size, void* frame, int64_t ts) {
	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoFrame( "
			"this : %p, "
			"size : %d "
			")",
			this,
			size
			);

	VideoFrameRateType type = VIDEO_FRAME_RATE_HOLD;;

	bool bFlag = false;
    mRuningMutex.lock();
    if( mbRunning ) {
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

    	if( mJniEncoder && mJniEncoderEncodeVideoMethodID ) {
    		env->CallBooleanMethod(mJniEncoder, mJniEncoderEncodeVideoMethodID, dataByteArray, size);
    	}

    	if( bFlag ) {
    		ReleaseEnv(isAttachThread);
    	}

    	bFlag = true;
    }
    mRuningMutex.unlock();

	FileLog("rtmpdump",
			"VideoHardEncoder::EncodeVideoFrame( "
			"this : %p, "
			"[%s], "
			"size : %d "
			")",
			this,
			bFlag?"Success":"Fail",
			size
			);

	return type;
}

void VideoHardEncoder::EncodeVideoHandle() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_MSG,
			"VideoHardEncoder::EncodeVideoHandle( "
			"this : %p, "
			"[Start], "
			"mJniEncoder : %p "
			")",
			this,
			mJniEncoder
			);

	JNIEnv* env;
	bool isAttachThread;
	bool bFlag = GetEnv(&env, &isAttachThread);

    while ( mbRunning ) {
		if( mJniEncoder && mJniEncoderGetEncodeVideoMethodID ) {
			jobject jVideoFrame = env->CallObjectMethod(mJniEncoder, mJniEncoderGetEncodeVideoMethodID);
			if( jVideoFrame ) {
				int timestamp = env->GetIntField(jVideoFrame, mJniVideoFrameTimestampMethodID);
				int size = env->GetIntField(jVideoFrame, mJniVideoFrameSizeMethodID);
				jbyteArray data = (jbyteArray)env->GetObjectField(jVideoFrame, mJniVideoFrameDataMethodID);
				jbyte* frame = env->GetByteArrayElements(data, 0);

				FileLevelLog(
						"rtmpdump",
						KLog::LOG_STAT,
						"VideoHardEncoder::EncodeVideoHandle( "
						"this : %p, "
						"[Get encode frame], "
						"jVideoFrame : %p, "
						"timestamp : %d "
						")",
						this,
						jVideoFrame,
						timestamp
						);

                // 分离Nalu
                bool bFinish = false;
                char* buffer = (char *)frame;
                int leftSize = size;
                int naluSize = 0;

                char* naluStart = NULL;
                char* naluEnd = NULL;

                int startCodeSize = 0;

                // 找到第一帧
                naluStart = FindNalu(buffer, size, startCodeSize);
                if( naluStart ) {
                	naluStart += startCodeSize;
                    leftSize -= (int)(naluStart - buffer);
                }

                while( naluStart ) {
                    naluSize = 0;

                    // 寻找Nalu
                    naluEnd = FindNalu(naluStart, leftSize, startCodeSize);
                    if( naluEnd != NULL ) {
                        // 找到Nalu
                        naluSize = (int)(naluEnd - naluStart);

                    } else {
                        // 最后一个Nalu
                        naluSize = leftSize;

                        bFinish = true;
                    }

                    FileLevelLog("rtmpdump",
                                 KLog::LOG_STAT,
                                 "VideoHardEncoder::EncodeVideoHandle( "
                                 "[Got Nalu], "
                                 "this : %p, "
                                 "frameType : 0x%x, "
                                 "naluSize : %d, "
                                 "leftSize : %d, "
                                 "bFinish : %s "
                                 ")",
                                 this,
                                 (*naluStart & 0x1f),
                                 naluSize,
                                 leftSize,
                                 bFinish?"true":"false"
                                 );

                    // 回调编码成功
                    if (NULL != mpCallback) {
                        mpCallback->OnEncodeVideoFrame(this, naluStart, naluSize, timestamp);
                    }

                    // 数据下标偏移
                    naluStart = naluEnd + startCodeSize;
                    leftSize -= naluSize;

                    if( bFinish ) {
                        break;
                    }
                }

				// 释放Java帧
				env->CallVoidMethod(mJniEncoder, mJniEncoderReleaseMethodID, jVideoFrame);

				env->ReleaseByteArrayElements(data, frame, 0);
				env->DeleteLocalRef(data);
				env->DeleteLocalRef(jVideoFrame);
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
			"VideoHardEncoder::EncodeVideoHandle( "
			"this : %p, "
			"[Exit] "
			"mJniEncoder : %p "
			")",
			this,
			mJniEncoder
			);
}

char* VideoHardEncoder::FindNalu(char* start, int size, int& startCodeSize) {
    static const char naluStartCode[] = {0x00, 0x00, 0x00, 0x01};
    static const char sliceStartCode[] = {0x00, 0x00, 0x01};
    startCodeSize = 0;
    char* nalu = NULL;
    char frameType = *start & 0x1F;

    for(int i = 0; i < size; i++) {
        // Only SPS or PPS need to seperate by slice start code
        if( frameType == 0x07 || frameType == 0x08 ) {
            if( i + sizeof(sliceStartCode) < size &&
               memcmp(start + i, sliceStartCode, sizeof(sliceStartCode)) == 0 ) {
            	startCodeSize = sizeof(sliceStartCode);
                nalu = start + i;
                break;
            }
        }

        if ( i + sizeof(naluStartCode) < size &&
            memcmp(start + i, naluStartCode, sizeof(naluStartCode)) == 0 ) {
        	startCodeSize = sizeof(naluStartCode);
            nalu = start + i;
            break;
        }
    }

    return nalu;
}

}
