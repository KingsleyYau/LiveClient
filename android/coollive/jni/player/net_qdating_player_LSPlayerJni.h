/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class net_qdating_player_LSPlayerJni */

#ifndef _Included_net_qdating_player_LSPlayerJni
#define _Included_net_qdating_player_LSPlayerJni
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    SetLogDir
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_SetLogDir
  (JNIEnv *, jclass, jstring);

/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    SetLogLevel
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_SetLogLevel
  (JNIEnv *, jclass, jint);

/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    Create
 * Signature: (Lnet/qdating/player/ILSPlayerCallbackJni;ZLnet/qdating/player/ILSVideoRendererJni;Lnet/qdating/player/ILSAudioRendererJni;Lnet/qdating/player/ILSVideoHardDecoderJni;Lnet/qdating/player/ILSVideoHardRendererJni;)J
 */
JNIEXPORT jlong JNICALL Java_net_qdating_player_LSPlayerJni_Create
  (JNIEnv *, jobject, jobject, jboolean, jobject, jobject, jobject, jobject);

/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    Destroy
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_Destroy
  (JNIEnv *, jobject, jlong);

/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    PlayUrl
 * Signature: (JLjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_net_qdating_player_LSPlayerJni_PlayUrl
  (JNIEnv *, jobject, jlong, jstring, jstring, jstring, jstring);

/*
 * Class:     net_qdating_player_LSPlayerJni
 * Method:    Stop
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_net_qdating_player_LSPlayerJni_Stop
  (JNIEnv *, jobject, jlong);

#ifdef __cplusplus
}
#endif
#endif
