/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow */

#ifndef _Included_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
#define _Included_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetHotLiveList
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetHotListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetHotLiveList
  (JNIEnv *, jclass, jint, jint, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetFollowingLiveList
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetFollowingListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetFollowingLiveList
  (JNIEnv *, jclass, jint, jint, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetLivingRoomAndInvites
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetLivingRoomAndInvitesCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetLivingRoomAndInvites
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetAudienceListInRoom
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetAudienceListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetAudienceListInRoom
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetAllGiftList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetAllGiftList
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetSendableGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetSendableGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetSendableGiftList
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetGiftDetail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetGiftDetail
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetEmotionList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetEmotionListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetEmotionList
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
 * Method:    GetImediateInviteInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetImediateInviteInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow_GetImediateInviteInfo
  (JNIEnv *, jclass, jstring, jobject);

#ifdef __cplusplus
}
#endif
#endif
