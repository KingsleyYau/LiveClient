#include "net_qdating_LSPublisherJni.h"

#include <JniGobalFunc.h>

#include <common/CommonFunc.h>

#include <rtmpdump/Rtmppublisher.h>
#include <rtmpdump/VideoEncoderH264.h>
#include <rtmpdump/AudioEncoderAAC.h>

class RtmpPublisherCallbackImp: public RtmpPublisherCallback {
public:
	RtmpPublisherCallbackImp(jobject callback) {
		JNIEnv* env;
		bool isAttachThread;
		bool bFlag = GetEnv(&env, &isAttachThread);

		timestampVideo = 0;
		timestampAudio = 0;

		audioEncodeFrame = NULL;
		audioEncodeFrameSize = 0;

		this->callback = env->NewGlobalRef(callback);

		if( bFlag ) {
			ReleaseEnv(isAttachThread);
		}
	}

	~RtmpPublisherCallbackImp() {
		JNIEnv* env;
		bool isAttachThread;
		bool bFlag = GetEnv(&env, &isAttachThread);

		if( audioEncodeFrame ) {
			delete[] audioEncodeFrame;
			audioEncodeFrame = NULL;
			audioEncodeFrameSize = 0;
		}

		if( callback ) {
			env->DeleteGlobalRef(callback);
			callback = NULL;
		}

		if( bFlag ) {
			ReleaseEnv(isAttachThread);
		}
	}

	void OnDisconnect(RtmpPublisher* publisher) {
		JNIEnv* env;
		bool isAttachThread;
		bool bFlag = GetEnv(&env, &isAttachThread);

//		// 回调图像
//		if( callback != NULL ) {
//			jclass jCallbackCls = env->GetObjectClass(callback);
//
//			if( jCallbackCls != NULL ) {
//				string signure = "()V";
//				jmethodID jMethodID = env->GetMethodID(
//						jCallbackCls, "OnDisconnect",
//						signure.c_str()
//						);
//
//				// 回调
//				if( jMethodID ) {
//					env->CallVoidMethod(callback, jMethodID);
//				}
//			}
//		}

		if( bFlag ) {
			ReleaseEnv(isAttachThread);
		}
	}

public:
	long long timestampVideo;
	long long timestampAudio;

	char* audioEncodeFrame;
	int audioEncodeFrameSize;

private:
    jobject callback;

};

JNIEXPORT void JNICALL Java_net_qdating_LSPublisherJni_GobalInit
  (JNIEnv *env, jclass) {
	KLog::SetLogDirectory("/sdcard/livestream");
}

JNIEXPORT jlong JNICALL Java_net_qdating_LSPublisherJni_Create
  (JNIEnv *env, jobject thiz, jobject callback) {
	bool bFlag = true;

	// RTMP发布器
	RtmpPublisher* publisher = new RtmpPublisher();

	FileLog("livestream",
			"LSPublisher::Create( "
			"publisher : %p, "
			"callback : %p "
			")",
			publisher,
			callback
			);

	// 视频编码器
	VideoEncoder* pVideoEncoder = NULL;
	VideoEncoderH264* pVideoEncoderImp = new VideoEncoderH264();
	bFlag = pVideoEncoderImp->Create(480, 640, 20, 600 * 1024, 2);
	pVideoEncoder = pVideoEncoderImp;
	publisher->SetVideoEncoder(pVideoEncoder);

	if( !bFlag ) {
		FileLog("livestream",
				"LSPublisher::Create( "
				"[Create Soft Video Decoder, Fail], "
				"publisher : %p, "
				"pVideoEncoder : %p "
				")",
				publisher,
				pVideoEncoder
				);
	}

	if( bFlag ) {
		// 音频编码器
		AudioEncoder* pAudioEncoder = NULL;
		AudioEncoderAAC* pAudioEncoderAACImp = new AudioEncoderAAC();
		bFlag = pAudioEncoderAACImp->Create(44100, 1, 16);
		pAudioEncoder = pAudioEncoderAACImp;
		publisher->SetAudioEncoder(pAudioEncoder);

		if( !bFlag ) {
			FileLog("livestream",
					"LSPublisher::Create( "
					"[Create Soft Audio Encoder, Fail], "
					"publisher : %p, "
					"pAudioDecoder : %p "
					")",
					publisher,
					pAudioEncoder
					);
		}
	}

    // RTMP发布器回调
	RtmpPublisherCallbackImp* pPublisherCallback = new RtmpPublisherCallbackImp(callback);
	publisher->SetCallback(pPublisherCallback);

	if( bFlag ) {
		FileLog("livestream",
				"LSPublisher::Create( "
				"[Success], "
				"publisher : %p "
				")",
				publisher
				);
	} else {
		FileLog("livestream",
				"LSPublisher::Create( "
				"[Fail], "
				"publisher : %p "
				")",
				publisher
				);
		// 清除
		Java_net_qdating_LSPublisherJni_Destroy(env, thiz, (long long)publisher);
		publisher = NULL;
	}

	return (long long)publisher;
}

JNIEXPORT void JNICALL Java_net_qdating_LSPublisherJni_Destroy
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	RtmpPublisher* publisher = (RtmpPublisher *)jpublisher;

	FileLog("livestream", "LSPublisher::Destroy( "
			"publisher : %p "
			")",
			publisher
			);

	// RTMP发布器回调
	RtmpPublisherCallbackImp* pPublisherCallback = (RtmpPublisherCallbackImp *)publisher->GetCallback();
	if( pPublisherCallback ) {
		delete pPublisherCallback;
	}

	VideoEncoderH264* pVideoEncoder = (VideoEncoderH264 *)publisher->GetVideoEncoder();
	if( pVideoEncoder ) {
		delete pVideoEncoder;
	}

	AudioEncoderAAC* pAudioEncoder = (AudioEncoderAAC *)publisher->GetAudioEncoder();
	if( pAudioEncoder ) {
		delete pAudioEncoder;
	}

	// 销毁RTMP播放器
	delete publisher;
}

JNIEXPORT jboolean JNICALL Java_net_qdating_LSPublisherJni_PublishUrl
  (JNIEnv *env, jobject thiz, jlong jpublisher, jstring jurl, jstring jrecordH264FilePath, jstring jrecordAACFilePath) {
	RtmpPublisher* publisher = (RtmpPublisher *)jpublisher;

	string url = JString2String(env, jurl);
	string recordH264FilePath = JString2String(env, jrecordH264FilePath);
	string recordAACFilePath = JString2String(env, jrecordAACFilePath);

	FileLog("livestream", "LSPublisher::PublishUrl( "
			"publisher : %p, "
			"url : %s "
			")",
			publisher,
			url.c_str()
			);

	return publisher->PublishUrl(url, recordH264FilePath, recordAACFilePath);
}

JNIEXPORT void JNICALL Java_net_qdating_LSPublisherJni_Stop
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	RtmpPublisher* publisher = (RtmpPublisher *)jpublisher;

	FileLog("livestream", "LSPublisher::Stop( "
			"publisher : %p "
			")",
			publisher
			);

	publisher->Stop();
}

JNIEXPORT void JNICALL Java_net_qdating_LSPublisherJni_SendVideoFrame
  (JNIEnv *env, jobject thiz, jlong jpublisher, jbyteArray jframe, jint size) {
	RtmpPublisher* publisher = (RtmpPublisher *)jpublisher;

//	jbyte* frame = NULL;
//	env->GetByteArrayRegion(jframe, 0, size, frame);
//
//	// 开始编码
//	VideoEncoderH264* pVideoEncoderImp = (VideoEncoderH264 *)publisher->GetVideoEncoder();
//	RtmpPublisherCallbackImp* pPublisherCallback = (RtmpPublisherCallbackImp *)publisher->GetCallback();
//
//	// 计算timestamp
//	int timestamp = 0;
//	long long now = getCurrentTime();
//	if( pPublisherCallback->timestampVideo != 0 ) {
//		timestamp = now - pPublisherCallback->timestampVideo;
//		pPublisherCallback->timestampVideo = now;
//	}
//	pVideoEncoderImp->EncodeVideoFrame((char *)frame, size, timestamp);

//	FileLog("livestream", "LSPublisher::SendVideoFrame( "
//			"publisher : %p, "
//			"frame : %p, "
//			"size : %d, "
//			"timestamp : %d "
//			")",
//			publisher,
//			frame,
//			size,
//			timestamp
//			);

//	while( true ) {
//		// 编码成功
//		VideoBuffer* frame = pVideoEncoderImp->GetBuffer();
//		if( frame ) {
//			publisher->AddVideoTimestamp(timestamp);
//			publisher->SendVideoFrame((char *)frame, size);
//			pVideoEncoderImp->ReleaseBuffer(frame);
//
//		} else {
//			break;
//		}
//	}

}

JNIEXPORT void JNICALL Java_net_qdating_LSPublisherJni_SendAudioFrame
  (JNIEnv *env, jobject thiz, jlong jpublisher, jint sampleRate, jint channelsPerFrame, jint bitPerSample, jbyteArray jframe, jint size) {
	RtmpPublisher* publisher = (RtmpPublisher *)jpublisher;

//	FileLog("livestream", "LSPublisher::SendAudioFrame( "
//			"publisher : %p, "
//			"sampleRate : %d, "
//			"channelsPerFrame : %d, "
//			"bitPerSample : %d, "
//			"jframe : %p, "
//			"size : %d "
//			")",
//			publisher,
//			sampleRate,
//			channelsPerFrame,
//			bitPerSample,
//			jframe,
//			size
//			);

	AudioEncoderAAC* pAudioEncoderImp = (AudioEncoderAAC *)publisher->GetAudioEncoder();
	RtmpPublisherCallbackImp* pPublisherCallback = (RtmpPublisherCallbackImp *)publisher->GetCallback();

	if( pPublisherCallback->audioEncodeFrame != NULL ) {
		int oldLen = pPublisherCallback->audioEncodeFrameSize;
		if( oldLen < size ) {
			delete[] pPublisherCallback->audioEncodeFrame;
			pPublisherCallback->audioEncodeFrame = NULL;
		}
	}

	if( pPublisherCallback->audioEncodeFrame == NULL ) {
		pPublisherCallback->audioEncodeFrameSize = size;
		pPublisherCallback->audioEncodeFrame = new char[size];
	}

	if( pPublisherCallback->audioEncodeFrame != NULL ) {
		env->GetByteArrayRegion(jframe, 0, size, (jbyte *)pPublisherCallback->audioEncodeFrame);
	}

	// 计算timestamp
	int timestamp = 0;
	long long now = getCurrentTime();
	if( pPublisherCallback->timestampAudio != 0 ) {
		timestamp = now - pPublisherCallback->timestampAudio;
		pPublisherCallback->timestampAudio = now;
	}

	// 开始音频编码
	pAudioEncoderImp->EncodeAudioFrame(pPublisherCallback->audioEncodeFrame, size, timestamp);

	FileLog("livestream", "LSPublisher::SendAudioFrame( "
			"publisher : %p, "
			"size : %d, "
			"timestamp : %d "
			")",
			publisher,
			size,
			timestamp
			);

	while( true ) {
		// 编码成功
		EncodeDecodeBuffer* bufferFrame = pAudioEncoderImp->GetBuffer();
		if( bufferFrame ) {
			publisher->AddAudioTimestamp(timestamp);
			publisher->SendAudioFrame(AFF_AAC, AFSR_KHZ_44, AFSS_BIT_16, AFST_MONO, (char *)bufferFrame, size);
			pAudioEncoderImp->ReleaseBuffer(bufferFrame);
		} else {
			break;
		}
	}
}
