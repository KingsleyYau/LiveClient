#include "net_qdating_LSPlayerJni.h"

#include <JniGobalFunc.h>

#include <LSPlayerImp.h>

JNIEXPORT void JNICALL Java_net_qdating_LSPlayerJni_GobalInit
  (JNIEnv *env, jclass cls) {
	KLog::SetLogDirectory("/sdcard/livestream");
}

JNIEXPORT jlong JNICALL Java_net_qdating_LSPlayerJni_Create
  (JNIEnv *env, jobject thiz, jobject callback, jobject videoRenderer, jobject audioRenderer, jobject videoDecoder) {
	bool bFlag = true;

	// RTMP播放器
	LSPlayerImp* player = new LSPlayerImp(callback, videoRenderer, audioRenderer, videoDecoder);

	FileLog("rtmpdump",
			"LSPlayer::Create( "
			"player : %p, "
			"callback : %p "
			")",
			player,
			callback
			);

	if( bFlag ) {
		FileLog("rtmpdump",
				"LSPlayer::Create( "
				"[Success], "
				"player : %p "
				")",
				player
				);
	} else {
		FileLog("rtmpdump",
				"LSPlayer::Create( "
				"[Fail], "
				"player : %p "
				")",
				player
				);
		Java_net_qdating_LSPlayerJni_Destroy(env, thiz, (long long)player);
		player = NULL;
	}

	return (long long)player;
}

JNIEXPORT void JNICALL Java_net_qdating_LSPlayerJni_Destroy
  (JNIEnv *env, jobject thiz, jlong jplayer) {
	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	FileLog("rtmpdump", "LSPlayer::Destroy( "
			"player : %p "
			")",
			player
			);

	// 销毁RTMP播放器
	delete player;
}

JNIEXPORT jboolean JNICALL Java_net_qdating_LSPlayerJni_PlayUrl
  (JNIEnv *env, jobject thiz, jlong jplayer, jstring jurl, jstring jrecordFilePath, jstring jrecordH264FilePath, jstring jrecordAACFilePath) {
	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	string url = JString2String(env, jurl);
	string recordFilePath = JString2String(env, jrecordFilePath);
	string recordH264FilePath = JString2String(env, jrecordH264FilePath);
	string recordAACFilePath = JString2String(env, jrecordAACFilePath);

	FileLog("rtmpdump", "LSPlayer::PlayUrl( "
			"player : %p, "
			"url : %s "
			")",
			player,
			url.c_str()
			);

	return player-> PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
}

JNIEXPORT void JNICALL Java_net_qdating_LSPlayerJni_Stop
  (JNIEnv *, jobject thiz, jlong jplayer) {
	LSPlayerImp* player = (LSPlayerImp *)jplayer;

	FileLog("rtmpdump", "LSPlayer::Stop( "
			"player : %p "
			")",
			player
			);

	player->Stop();
}
