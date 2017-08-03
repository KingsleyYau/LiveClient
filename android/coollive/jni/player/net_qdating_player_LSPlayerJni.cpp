#include <common/KLog.h>

#include <AndroidCommon/JniCommonFunc.h>

#include <rtmpdump/android/JavaItem.h>

#include <LSPlayerImp.h>

#include <net_qdating_player_LSPlayerJni.h>

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
	FileLog("rtmpdump", "JNI_OnLoad( lsplayer )");
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

	jobject jLSVideoFrameItem;
	InitClassHelper(env, LS_VIDEO_ITEM_CLASS, &jLSVideoFrameItem);

	return JNI_VERSION_1_4;
}

JNIEXPORT jlong JNICALL Java_net_qdating_player_LSPlayerJni_Create
  (JNIEnv *env, jobject thiz, jobject callback, jobject videoRenderer, jobject audioRenderer, jobject videoDecoder) {
	// RTMP播放器
	LSPlayerImp* player = new LSPlayerImp(callback, videoRenderer, audioRenderer, videoDecoder);

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerJni::Create( "
			"player : %p, "
			"callback : %p "
			")",
			player,
			callback
			);

	return (long long)player;
}

JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_Destroy
  (JNIEnv *env, jobject thiz, jlong jplayer) {
	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerJni::Destroy( "
			"player : %p "
			")",
			player
			);

	delete player;
}

JNIEXPORT jboolean JNICALL Java_net_qdating_player_LSPlayerJni_PlayUrl
  (JNIEnv *env, jobject thiz, jlong jplayer, jstring jurl, jstring jrecordFilePath, jstring jrecordH264FilePath, jstring jrecordAACFilePath) {
	bool bFlag = true;

	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	string url = JString2String(env, jurl);
	string recordFilePath = JString2String(env, jrecordFilePath);
	string recordH264FilePath = JString2String(env, jrecordH264FilePath);
	string recordAACFilePath = JString2String(env, jrecordAACFilePath);

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerJni::PlayUrl( "
			"player : %p, "
			"url : %s "
			")",
			player,
			url.c_str()
			);

	bFlag = player->PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);

	if( bFlag ) {
		FileLevelLog(
				"rtmpdump",
				KLog::LOG_WARNING,
				"LSPlayerJni::PlayUrl( "
				"[Success], "
				"player : %p, "
				"url : %s "
				")",
				player,
				url.c_str()
				);
	} else {
		FileLevelLog(
				"rtmpdump",
				KLog::LOG_WARNING,
				"LSPlayerJni::PlayUrl( "
				"[Fail], "
				"player : %p, "
				"url : %s "
				")",
				player,
				url.c_str()
				);
	}

	return bFlag;
}

JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_Stop
  (JNIEnv *, jobject thiz, jlong jplayer) {
	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerJni::Stop( "
			"player : %p "
			")",
			player
			);

	player->Stop();

	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"LSPlayerJni::Stop( "
			"[Success], "
			"player : %p "
			")",
			player
			);
}
