/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_anchor_im_IMClient */

#ifndef _Included_com_qpidnetwork_anchor_im_IMClient
#define _Included_com_qpidnetwork_anchor_im_IMClient
#ifdef __cplusplus
extern "C" {
#endif

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    IMSetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_anchor_im_IMClient_IMSetLogDirectory
        (JNIEnv *, jclass, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    init
 * Signature: ([Ljava/lang/String;Lcom/qpidnetwork/livemodule/im/listener/IMClientListener;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_init
  (JNIEnv *, jclass, jobjectArray, jobject);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    GetReqId
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_anchor_im_IMClient_GetReqId
  (JNIEnv *, jclass);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    IsInvalidReqId
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_IsInvalidReqId
  (JNIEnv *, jclass, jint);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    Login
 * Signature: (Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_Login
  (JNIEnv *, jclass, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    Logout
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_Logout
  (JNIEnv *, jclass);


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    PublicRoomIn
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_PublicRoomIn
        (JNIEnv *, jclass, jint);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    RoomIn
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_RoomIn
  (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    RoomOut
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_RoomOut
  (JNIEnv *, jclass, jint, jstring);


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendRoomMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendRoomMsg
  (JNIEnv *, jclass, jint, jstring, jstring, jstring, jobjectArray);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendGift
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZIZIII)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendGift
  (JNIEnv *, jclass, jint, jstring, jstring, jstring, jstring, jboolean, jint, jboolean, jint, jint, jint);


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendImmediatePrivateInvite
 * Signature: (ILjava/lang/String;Ljava/lang/String;Z)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendImmediatePrivateInvite
  (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    GetInviteInfo
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_GetInviteInfo
  (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    EnterhangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_EnterHangoutRoom
    (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    LeaveHangoutRoom
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_LeaveHangoutRoom
        (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendHangoutGift
 * Signature: (ILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendHangoutGift
        (JNIEnv *, jclass, jint, jstring, jstring, jstring, jstring, jstring, jboolean, jint, jboolean, jint, jint, jint, jboolean);


/*
 * Class:     com_qpidnetwork_anchor_im_IMClient
 * Method:    SendHangoutMsg
 * Signature: (ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL Java_com_qpidnetwork_anchor_im_IMClient_SendHangoutMsg
        (JNIEnv *, jclass, jint, jstring, jstring, jstring, jobjectArray);

#ifdef __cplusplus
}
#endif
#endif
