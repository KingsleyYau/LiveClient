#include <common/KLog.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <rtmpdump/android/JavaItem.h>

#include <LSPublisherImp.h>

#include <net_qdating_publisher_LSPublisherJni.h>

#include "../LSVersion.h"

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
	gJavaVM = vm;

	// Get JNI
	JNIEnv* env;
	if (JNI_OK != vm->GetEnv(reinterpret_cast<void**> (&env),
                           JNI_VERSION_1_4)) {
		FileLevelLog("rtmpdump", KLog::LOG_ERR_SYS, "JNI_OnLoad( Could not get JNI env )");
		return -1;
	}

	KLog::SetLogDirectory("/sdcard/coollive");
	KLog::SetLogLevel(KLog::LOG_WARNING);

	FileLevelLog("rtmpdump", KLog::LOG_ERR_SYS, "JNI_OnLoad( lspublisher, version : %s )", LS_VERSION);

	jobject jLSVideoFrameItem;
	InitClassHelper(env, LS_VIDEO_ITEM_CLASS, &jLSVideoFrameItem);

	return JNI_VERSION_1_4;
}

JNIEXPORT jlong JNICALL Java_net_qdating_publisher_LSPublisherJni_Create
  (JNIEnv *env, jobject thiz, jobject callback, jobject videoEncoder, jobject videoRenderer, jint width, jint height, jint bitRate, jint keyFrameInterval, jint fps) {
	// RTMP推送器
	LSPublisherImp* publisher = new LSPublisherImp(callback, videoEncoder, videoRenderer, width, height, bitRate, keyFrameInterval, fps);

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::Create( "
			"publisher : %p, "
			"callback : %p, "
			"videoEncoder : %p "
			")",
			publisher,
			callback,
			videoEncoder
			);

	return (long long)publisher;
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_Destroy
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::Destroy( "
			"publisher : %p "
			")",
			publisher
			);

	delete publisher;
}

JNIEXPORT jboolean JNICALL Java_net_qdating_publisher_LSPublisherJni_PublishUrl
  (JNIEnv *env, jobject thiz, jlong jpublisher, jstring jurl, jstring jrecordH264FilePath, jstring jrecordAACFilePath) {
	bool bFlag = true;

	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	string url = JString2String(env, jurl);
	string recordH264FilePath = JString2String(env, jrecordH264FilePath);
	string recordAACFilePath = JString2String(env, jrecordAACFilePath);

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::PublishUrl( "
			"publisher : %p, "
			"url : %s "
			")",
			publisher,
			url.c_str()
			);

	bFlag = publisher->PublishUrl(url, recordH264FilePath, recordAACFilePath);

	if( bFlag ) {
		FileLevelLog(
				"rtmpdump",
				KLog::LOG_WARNING,
				"LSPublisherJni::PublishUrl( "
				"[Success], "
				"publisher : %p, "
				"url : %s "
				")",
				publisher,
				url.c_str()
				);
	} else {
		FileLevelLog(
				"rtmpdump",
				KLog::LOG_WARNING,
				"LSPublisherJni::PublishUrl( "
				"[Fail], "
				"publisher : %p, "
				"url : %s "
				")",
				publisher,
				url.c_str()
				);
	}

	return bFlag;
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_PushVideoFrame
  (JNIEnv *env, jobject thiz, jlong jpublisher, jbyteArray data, jint size, jint width, jint height) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	jbyte* frame = env->GetByteArrayElements(data, 0);
//	int size = env->GetArrayLength(data);

	publisher->PushVideoFrame((char *)frame, size, width, height);

	env->ReleaseByteArrayElements(data, frame, 0);
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_PausePushVideo
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;
	publisher->PausePushVideo();
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_ResumePushVideo
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;
	publisher->ResumePushVideo();
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_PushAudioFrame
  (JNIEnv *env, jobject thiz, jlong jpublisher, jbyteArray data, jint size) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	jbyte* frame = env->GetByteArrayElements(data, 0);

	publisher->PushAudioFrame((char *)frame, size);

	env->ReleaseByteArrayElements(data, frame, 0);
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_ChangeVideoRotate
  (JNIEnv *env, jobject thiz, jlong jpublisher, jint rotate) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::ChangeVideoRotate( "
			"publisher : %p, "
			"rotate : %d "
			")",
			publisher,
			rotate
			);

	publisher->ChangeVideoRotate(rotate);
}

JNIEXPORT void JNICALL Java_net_qdating_publisher_LSPublisherJni_Stop
  (JNIEnv *env, jobject thiz, jlong jpublisher) {
	LSPublisherImp* publisher = (LSPublisherImp *)jpublisher;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::Stop( "
			"publisher : %p "
			")",
			publisher
			);

	publisher->Stop();

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPublisherJni::Stop( "
			"[Success], "
			"publisher : %p "
			")",
			publisher
			);
}
