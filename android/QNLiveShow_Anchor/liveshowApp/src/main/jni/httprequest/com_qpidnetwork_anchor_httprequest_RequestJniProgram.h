/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_anchor_httprequest_RequestJniProgram */

#ifndef _Included_com_qpidnetwork_anchor_httprequest_RequestJniProgram
#define _Included_com_qpidnetwork_anchor_httprequest_RequestJniProgram
#ifdef __cplusplus
extern "C" {
#endif

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetProgramList
 * Signature: (IIILcom/qpidnetwork/anchor/httprequest/OnGetProgramListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetProgramList
  (JNIEnv *, jclass, jint, jint, jint, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetNoReadNumProgram
 * Signature: (Lcom/qpidnetwork/anchor/httprequest/OnGetNoReadNumProgramCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetNoReadNumProgram
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    GetShowRoomInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/anchor/httprequest/OnGetShowRoomInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_GetShowRoomInfo
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniProgram
 * Method:    CheckPublicRoomType
 * Signature: (Lcom/qpidnetwork/anchor/httprequest/OnCheckPublicRoomTypeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniProgram_CheckPublicRoomType
        (JNIEnv *, jclass, jobject);



#ifdef __cplusplus
}
#endif
#endif
