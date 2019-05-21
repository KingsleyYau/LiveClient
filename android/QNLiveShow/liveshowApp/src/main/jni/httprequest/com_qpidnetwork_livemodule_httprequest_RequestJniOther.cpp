/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniOther.cpp
 *
 *  Created on: 2017-6-13
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniOther.h"
#include <common/command.h>

#define OS_TYPE "Android"
/*********************************** 6.1. 同步配置    ****************************************/

class RequestGetConfigCallback : public IRequestGetConfigCallback{
	void OnGetConfig(HttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const HttpConfigItem& configItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig( success : %s, task : %p, isAttachThread:%d post_stamp_url:%s)", success?"true":"false", task, isAttachThread, configItem.postStampUrl.c_str());

        jobject jItem = getSynConfigItem(env, configItem);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_CONFIG_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSynConfig", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItem != NULL){
			env->DeleteLocalRef(jItem);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig(end)");

	}
};

RequestGetConfigCallback gRequestGetConfigCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SynConfig
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnSynConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SynConfig
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SynConfig()start %p", &gConfigRequestManager);
    taskId = gHttpRequestController.GetConfig(&gConfigRequestManager,
                                        &gRequestGetConfigCallback);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SynConfig()end %p", &gConfigRequestManager);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.2. 获取账号余额    ****************************************/

class RequestGetLeftCreditCallback : public IRequestGetLeftCreditCallback{
	void OnGetLeftCredit(HttpGetLeftCreditTask* task, bool success, int errnum, const string& errmsg, const HttpLeftCreditItem& leftCreditItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCredit( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;DI)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAccountBalance", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCredit( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, leftCreditItem.credit, leftCreditItem.coupon);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetLeftCreditCallback gRequestGetLeftCreditCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetAccountBalance
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetAccountBalanceCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetAccountBalance
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAccountBalance()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetLeftCredit(&gHttpRequestManager,
    									&gRequestGetLeftCreditCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.3. 添加/取消收藏   ****************************************/
class RequestSetFavoriteCallback : public IRequestSetFavoriteCallback{
	void OnSetFavorite(HttpSetFavoriteTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetFavorite( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetFavorite( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestSetFavoriteCallback gRequestSetFavoriteCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    AddOrCancelFavorite
 * Signature: (Ljava/lang/String;Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_AddOrCancelFavorite
  (JNIEnv *env, jclass cls, jstring userId, jstring roomId, jboolean isFav, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AddOrCancelFavorite( userId : %s, roomId : %s, isFav : %d )",
			JString2String(env, userId).c_str(), JString2String(env, roomId).c_str(), isFav);
    jlong taskId = -1;
    taskId = gHttpRequestController.SetFavorite(&gHttpRequestManager,
    									JString2String(env, userId),
    									JString2String(env, roomId),
    									isFav,
    									&gRequestSetFavoriteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.4. 获取QN广告列表   ****************************************/

class RequestGetAdAnchorListCallback : public IRequestGetAdAnchorListCallback{
	void OnGetAdAnchorList(HttpGetAdAnchorListTask* task, bool success, int errnum, const string& errmsg, const AdItemList& list){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetAdAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getAdListArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HOTLIST_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAdAnchorList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetAdAnchorList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItemArray != NULL){
			env->DeleteLocalRef(jItemArray);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestGetAdAnchorListCallback gRequestGetAdAnchorListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetAdAnchorList
 * Signature: (ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetAdAnchorList
  (JNIEnv *env, jclass cls, jint number,  jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAdAnchorList( number : %d)",
            number);
    jlong taskId = -1;
    taskId = gHttpRequestController.GetAdAnchorList(&gHttpRequestManager,
    									number,
    									&gRequestGetAdAnchorListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.5. 关闭QN广告列表  ****************************************/
class RequestCloseAdAnchorListCallback : public IRequestCloseAdAnchorListCallback{
	void OnCloseAdAnchorList(HttpCloseAdAnchorListTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCloseAdAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCloseAdAnchorList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestCloseAdAnchorListCallback gRequestCloseAdAnchorListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    CloseAdAnchorList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_CloseAdAnchorList
  (JNIEnv *env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CloseAdAnchorList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.CloseAdAnchorList(&gHttpRequestManager,
    									&gRequestCloseAdAnchorListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.6. 获取手机验证码  ****************************************/
class RequestGetPhoneVerifyCodeCallback : public IRequestGetPhoneVerifyCodeCallback{
	void OnGetPhoneVerifyCode(HttpGetPhoneVerifyCodeTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPhoneVerifyCode( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPhoneVerifyCode( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestGetPhoneVerifyCodeCallback gRequestGetPhoneVerifyCodeCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetPhoneVerifyCode
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetPhoneVerifyCode
  (JNIEnv *env, jclass cls, jstring country, jstring areaCode, jstring phoneNo, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPhoneVerifyCode( country : %s, areaCode : %s, phoneNo : %s)",
			JString2String(env, country).c_str(), JString2String(env, areaCode).c_str(), JString2String(env, phoneNo).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetPhoneVerifyCode(&gHttpRequestManager,
    													JString2String(env, country),
    													JString2String(env, areaCode),
    													JString2String(env, phoneNo),
    													&gRequestGetPhoneVerifyCodeCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.7. 提交手机验证码  ****************************************/
class RequestSubmitPhoneVerifyCodeCallback : public IRequestSubmitPhoneVerifyCodeCallback{
	void OnSubmitPhoneVerifyCode(HttpSubmitPhoneVerifyCodeTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSubmitPhoneVerifyCode( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSubmitPhoneVerifyCode( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestSubmitPhoneVerifyCodeCallback gRequestSubmitPhoneVerifyCodeCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetPhoneVerifyCode
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SubmitPhoneVerifyCode
(JNIEnv *env, jclass cls, jstring country, jstring areaCode, jstring phoneNo, jstring verifyCode, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SubmitPhoneVerifyCode( country : %s, areaCode : %s, phoneNo : %s, verifyCode : %s)",
			JString2String(env, country).c_str(), JString2String(env, areaCode).c_str(), JString2String(env, phoneNo).c_str(), JString2String(env, verifyCode).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SubmitPhoneVerifyCode(&gHttpRequestManager,
    													JString2String(env, country),
    													JString2String(env, areaCode),
    													JString2String(env, phoneNo),
    													JString2String(env, verifyCode),
    													&gRequestSubmitPhoneVerifyCodeCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.8.提交流媒体服务器测速结果  ****************************************/
class RequestServerSpeedCallback : public IRequestServerSpeedCallback {
	void OnServerSpeed(HttpServerSpeedTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestServerSpeedCallback gRequestServerSpeedCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    ServerSpeed
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_ServerSpeed
  (JNIEnv *env, jclass cls, jstring sid, jint res, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( sid : %s, res : %d )",
			JString2String(env, sid).c_str(), res);
    jlong taskId = -1;
    taskId = gHttpRequestController.ServerSpeed(&gHttpRequestManager,
    													JString2String(env, sid),
    													res,
    													&gRequestServerSpeedCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 6.9.获取Hot/Following列表头部广告  ****************************************/
class RequestBannerCallback : public IRequestBannerCallback {
	void OnBanner(HttpBannerTask* task, bool success, int errnum, const string& errmsg, const string& bannerImg, const string& bannerLink, const string& bannerName) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnBanner( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onBanner", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnBanner( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jbannerImg = env->NewStringUTF(bannerImg.c_str());
				jstring jbannerLink = env->NewStringUTF(bannerLink.c_str());
				jstring jbannerName = env->NewStringUTF(bannerName.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jbannerImg, jbannerLink, jbannerName);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jbannerImg);
				env->DeleteLocalRef(jbannerLink);
				env->DeleteLocalRef(jbannerName);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestBannerCallback gRequestBannerCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    Banner
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_Banner
  (JNIEnv *env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Banner()");
    jlong taskId = -1;
    taskId = gHttpRequestController.Banner(&gHttpRequestManager,
    										&gRequestBannerCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;

}

/*********************************** 6.10.获取主播/观众信息  ****************************************/
class RequestGetUserInfoCallback : public IRequestGetUserInfoCallback {
	void OnGetUserInfo(HttpGetUserInfoTask* task, bool success, int errnum, const string& errmsg, const HttpUserInfoItem& userItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetUserInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = getUserInfoItem(env, userItem);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_USERINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetUserInfo", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetUserInfo( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItem != NULL){
			env->DeleteLocalRef(jItem);
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetUserInfoCallback gRequestGetUserInfoCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetUserInfo
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnGetUserInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetUserInfo
  (JNIEnv *env, jclass cls, jstring userId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetUserInfo( userId : %s )",
			JString2String(env, userId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetUserInfo(&gHttpRequestManager,
    										JString2String(env, userId),
    										&gRequestGetUserInfoCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;

}

/*********************************** 6.17.获取主界面未读数量  ****************************************/
class RequestGetTotalNoreadNumCallback : public IRequestGetTotalNoreadNumCallback {
	void OnGetTotalNoreadNum(HttpGetTotalNoreadNumTask* task, bool success, int errnum, const string& errmsg, const HttpMainNoReadNumItem& item) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetMainUnreadNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		jobject jItem = getMainNoReadNumItem(env, item);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_MAINUNREADNUM_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetMainUnreadNum", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetMainUnreadNum( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
                env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItem != NULL){
			env->DeleteLocalRef(jItem);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestGetTotalNoreadNumCallback gRequestGetTotalNoreadNumCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetMainUnreadNum
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetMainUnreadNumCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetMainUnreadNum
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetMainUnreadNum()");
	jlong taskId = -1;
	taskId = gHttpRequestController.GetTotalNoreadNum(&gHttpRequestManager,
										   &gRequestGetTotalNoreadNumCallback);
	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;

}

/*********************************** 6.18.查询个人信息  ****************************************/
class RequestGetMyProfileCallback : public IRequestGetMyProfileCallback {
	void OnGetMyProfile(HttpGetMyProfileTask* task, bool success, const string& errnum, const string& errmsg, const HttpProfileItem& profileItem) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetMyProfile( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		jobject jItem = getMyProfileItem(env, profileItem);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_LSPROFILE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetMyProfile", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetMyProfile( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItem != NULL){
			env->DeleteLocalRef(jItem);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestGetMyProfileCallback gRequestGetMyProfileCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetMyProfile
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetMyProfile()");
	jlong taskId = -1;
	taskId = gHttpRequestController.GetMyProfile(&gDomainRequestManager,
													  &gRequestGetMyProfileCallback);
	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 6.19.修改个人信息  ****************************************/
class RequestUpdateProfileCallback : public IRequestUpdateProfileCallback {
	void OnUpdateProfile(HttpUpdateProfileTask* task, bool success, const string& errnum, const string& errmsg, bool isModify) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUpdateProfile( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "Z";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onUpdateMyProfile", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUpdateProfile( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, isModify);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestUpdateProfileCallback gRequestUpdateProfileCallback;
/*
 * Class:     com_qpidnetwork_request_RequestJniProfile
 * Method:    UpdateProfile
 * Signature: (IIIIIIIIIIILjava/lang/String;Lcom/qpidnetwork/request/OnUpdateMyProfileCallback;)J
 */
JNIEXPORT jlong Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_UpdateProfile
		(JNIEnv *env, jclass, jint weight, jint height, jint language, jint ethnicity, jint religion,
		 jint education, jint profession, jint income, jint children, jint smoke,
		 jint drink, jstring resume, jobjectArray interests, jint zodiac, jobject callback) {
	jlong taskId = -1;


	list<string> interestList;
	jint len = env->GetArrayLength(interests);
	for(int i = 0; i < len; i++) {
		jstring interest = (jstring)env->GetObjectArrayElement(interests, i);
		string cpInterest = JString2String(env, interest);
		interestList.push_back(cpInterest);
	}

	taskId = gHttpRequestController.UpdateProfile(&gDomainRequestManager, weight, height, language, ethnicity, religion,
														education, profession, income, children, smoke, drink, JString2String(env, resume), interestList, zodiac, &gRequestUpdateProfileCallback);


	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);


	return taskId;
}

/*********************************** 6.20.检查客户端更新  ****************************************/
class RequestVersionCheckCallback : public IRequestVersionCheckCallback {
	void OnVersionCheck(HttpVersionCheckTask* task, bool success, const string& errnum, const string& errmsg, const HttpVersionCheckItem& versionItem) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnVersionCheck( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		jobject jItem = getVersionCheckItem(env, versionItem);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_LSVERSIONCHECK_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onOtherVersionCheck", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnVersionCheck( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItem != NULL){
			env->DeleteLocalRef(jItem);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestVersionCheckCallback gRequestVersionCheckCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_VersionCheck
		(JNIEnv *env, jclass cls, jint currVersion, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::VersionCheck(currVersion:%d)", currVersion);
	jlong taskId = -1;
	taskId = gHttpRequestController.VersionCheck(&gDomainRequestManager,
												 currVersion,
												 &gRequestVersionCheckCallback);
	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 6.21.开始编辑简介触发计时  ****************************************/
class RequestStartEditResumeCallback : public IRequestStartEditResumeCallback {
	void OnStartEditResume(HttpStartEditResumeTask* task, bool success, const string& errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnStartEditResume( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnStartEditResume( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestStartEditResumeCallback gRequestStartEditResumeCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_StartEditResume
          (JNIEnv *env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::StartEditResume()");
    jlong taskId = -1;
    taskId = gHttpRequestController.StartEditResume(&gDomainRequestManager,
          												 &gRequestStartEditResumeCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
 }

/*********************************** 6.22.开始编辑简介触发计时  ****************************************/
class RequestPhoneInfoCallback : public IRequestPhoneInfoCallback {
	void OnPhoneInfo(HttpPhoneInfoTask* task, bool success, const string& errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnPhoneInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnPhoneInfo( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};
RequestPhoneInfoCallback gRequestPhoneInfoCallback;
 /*
  * Class:     com_qpidnetwork_request_RequestJniOther
  * Method:    PhoneInfo
  * Signature: (Ljava/lang/String;ILjava/lang/String;ZIDIILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)J
  */
 JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_PhoneInfo
   (JNIEnv *env, jclass cls, jstring manId, jint verCode, jstring verName, jint action, jint siteId
    , jdouble density, jint width, jint height, jstring lineNumber
    , jstring simOptName, jstring simOpt, jstring simCountryIso, jstring simState
    , jint phoneType, jint networkType, jstring deviceId
    , jobject callback)
 {
 	jlong taskId = -1;
 	const char *cpTemp = NULL;

 	// manId
 	string strManId("");
 	if (NULL != manId) {
 		strManId = JString2String(env, manId);
 	}

 	// verName
 	string strVerName("");
 	if (NULL != verName) {
 		strVerName = JString2String(env, verName);
 	}

 	// lineNumber
 	string strLineNumber("");
 	if (NULL != lineNumber) {
 		strLineNumber = JString2String(env, lineNumber);

 	}

 	// simOptName
 	string strSimOptName("");
 	if (NULL != simOptName) {
 		strSimOptName = JString2String(env, simOptName);

 	}

 	// simOpt
 	string strSimOpt("");
 	if (simOpt) {
 		strSimOpt = JString2String(env, simOpt);

 	}

 	// simCountryIso
 	string strSimCountryIso("");
 	if (NULL != simCountryIso) {
 		strSimCountryIso = JString2String(env, simCountryIso);
 	}

 	// simState
 	string strSimState("");
 	if (NULL != simState) {
 		strSimState = JString2String(env, simState);
 	}

 	// deviceId
 	string strDeviceId("");
 	if (NULL != deviceId) {
 		strDeviceId = JString2String(env, deviceId);
 	}

 	string strDensityDpi = GetPhoneDensityDPI();
 	string strModel = GetPhoneModel();
 	string strManufacturer = GetPhoneManufacturer();
 	string strOS = OS_TYPE;
 	string strRelease = GetPhoneBuildVersion();
 	string strSDK = GetPhoneBuildSDKVersion();
 	string strLanguage = GetPhoneLocalLanguage();
 	string strCountry = GetPhoneLocalRegion();

 	// 发出请求
 	taskId = gHttpRequestController.PhoneInfo(&gDomainRequestManager, strManId, verCode, strVerName, action, (HTTP_OTHER_SITE_TYPE)siteId
 			, density, width, height, strDensityDpi, strModel, strManufacturer, strOS, strRelease, strSDK, strLanguage, strCountry
 			, strLineNumber , strSimOptName, strSimOpt, strSimCountryIso, strSimState
 			, phoneType, networkType, strDeviceId, &gRequestPhoneInfoCallback);

 	if (taskId != -1) {
 		// 保存callback
 		jobject jObj = NULL;
 		if (NULL != callback) {
 			jobject obj = env->NewGlobalRef(callback);
            putCallbackIntoMap(taskId, obj);
 		}
 		FileLog("LIVESHOW_HTTP_LOG", "LShttprequestJNI::PhoneInfo() taskId:%lld, callback:%p, jObj:%p", taskId, callback, jObj);
 	}
 	else {
 		FileLog("LIVESHOW_HTTP_LOG", "LShttprequestJNI::PhoneInfo() fails. "
 				"taskId:%lld", taskId);
 	}

 	return taskId;
 }