/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow */

#ifndef _Included_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
#define _Included_com_qpidnetwork_livemodule_httprequest_RequestJniLiveShow
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetNoReadNumProgram
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetNoReadNumProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetNoReadNumProgram
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetProgramList
 * Signature: (IIILcom/qpidnetwork/livemodule/httprequest/OnGetProgramListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetProgramList
        (JNIEnv *, jclass, jint, jint, jint, jobject);


/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    BuyProgram
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnBuyProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_BuyProgram
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    FollowShow
 * Signature: (Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnFollowShowCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_FollowShow
        (JNIEnv *, jclass, jstring, jboolean, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    GetShowRoomInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetShowRoomInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_GetShowRoomInfo
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniProgram
 * Method:    ShowListWithAnchorId
 * Signature: (IIILjava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnShowListWithAnchorIdCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniProgram_ShowListWithAnchorId
        (JNIEnv *, jclass, jint, jint, jint, jstring, jobject);


#ifdef __cplusplus
}
#endif
#endif
