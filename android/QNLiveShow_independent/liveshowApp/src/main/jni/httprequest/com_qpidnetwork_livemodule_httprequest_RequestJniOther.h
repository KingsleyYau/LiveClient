/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_qpidnetwork_livemodule_httprequest_RequestJniOther */

#ifndef _Included_com_qpidnetwork_livemodule_httprequest_RequestJniOther
#define _Included_com_qpidnetwork_livemodule_httprequest_RequestJniOther
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SynConfig
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnSynConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SynConfig
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetAccountBalance
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetAccountBalanceCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetAccountBalance
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    AddOrCancelFavorite
 * Signature: (Ljava/lang/String;Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_AddOrCancelFavorite
  (JNIEnv *, jclass, jstring, jstring, jboolean, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetAdAnchorList
 * Signature: (ILcom/qpidnetwork/livemodule/httprequest/OnGetAdAnchorListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetAdAnchorList
  (JNIEnv *, jclass, jint, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    CloseAdAnchorList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_CloseAdAnchorList
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetPhoneVerifyCode
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetPhoneVerifyCode
  (JNIEnv *, jclass, jstring, jstring, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SubmitPhoneVerifyCode
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SubmitPhoneVerifyCode
  (JNIEnv *, jclass, jstring, jstring, jstring, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    ServerSpeed
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_ServerSpeed
  (JNIEnv *, jclass, jstring, jint, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    Banner
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnBannerCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_Banner
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetUserInfo
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnGetUserInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetUserInfo
  (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetShareLink
 * Signature: (Ljava/lang/String;Ljava/lang/String;IIILcom/qpidnetwork/livemodule/httprequest/OnGetShareLinkCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetShareLink
        (JNIEnv *, jclass, jstring, jstring, jint, jint, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SetShareSuc
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnSetShareSucCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SetShareSuc
        (JNIEnv *, jclass, jstring, jobject);


/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SubmitFeedBack
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSSubmitFeedBackCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SubmitFeedBack
        (JNIEnv *, jclass, jstring, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetManBaseInfo
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSGetManBaseInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetManBaseInfo
        (JNIEnv *, jclass, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SetManBaseInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSSetManBaseInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SetManBaseInfo
        (JNIEnv *, jclass, jstring, jobject);

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    UploadCrashFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSUploadCrashFileCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_UploadCrashFile
        (JNIEnv *, jclass, jstring, jstring, jstring, jobject);


#ifdef __cplusplus
}
#endif
#endif
