/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniOther.cpp
 *
 *  Created on: 2017-6-13
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniOther.h"


/*********************************** 6.1. 同步配置    ****************************************/

class RequestGetConfigCallback : public IRequestGetConfigCallback{
	void OnGetConfig(HttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const HttpConfigItem& configItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

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
	void OnGetLeftCredit(HttpGetLeftCreditTask* task, bool success, int errnum, const string& errmsg, double credit){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCredit( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;D)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAccountBalance", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCredit( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, credit);
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
	void OnGetAdAnchorList(HttpGetAdAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& list){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetAdAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getHotListArray(env, list);
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
  (JNIEnv *env, jclass cls, jint number, jobject callback) {
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

/*********************************** 6.11.获取分享链接  ****************************************/
class RequestGetShareLinkCallback : public IRequestGetShareLinkCallback {
	void OnGetShareLink(HttpGetShareLinkTask* task, bool success, int errnum, const string& errmsg, const string& shareId, const string& shareLink) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetShareLink( success : %s, task : %p, shareId : %s, sharelink : %s, isAttachThread:%d )", success?"true":"false", task, shareId.c_str(), shareLink.c_str(), isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetShareLink", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetShareLink( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jshareId = env->NewStringUTF(shareId.c_str());
				jstring jshareLink = env->NewStringUTF(shareLink.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jshareId, jshareLink);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jshareId);
				env->DeleteLocalRef(jshareLink);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetShareLinkCallback gRequestGetShareLinkCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetShareLink
 * Signature: (Ljava/lang/String;Ljava/lang/String;IIILcom/qpidnetwork/livemodule/httprequest/OnGetShareLinkCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetShareLink
		(JNIEnv *env, jclass cls, jstring shareUserId, jstring anchorId, jint shareType, jint sharePageType, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetShareLink( shareUserId : %s, anchorId : %s, shareType : %d, sharePageType : %d )",
			JString2String(env, shareUserId).c_str(), JString2String(env, anchorId).c_str(), shareType, sharePageType);
	jlong taskId = -1;
    ShareType jshareType = IntToShareTypeOperateType(shareType);
    SharePageType jsharePageType = IntToSharePageTypeOperateType(sharePageType);
	taskId = gHttpRequestController.GetShareLink(&gHttpRequestManager,
												JString2String(env, shareUserId),
                                                 JString2String(env, anchorId),
                                                 jshareType,
                                                 jsharePageType,
												&gRequestGetShareLinkCallback);
	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 6.12.分享链接成功 ****************************************/
class RequestSetShareSucCallback : public IRequestSetShareSucCallback {
    void OnSetShareSuc(HttpSetShareSucTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetShareSuc( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSetShareSuc", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetShareSuc( callback : %p, signature : %s )",
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

RequestSetShareSucCallback gRequestSetShareSucCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SetShareSuc
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnSetShareSucCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SetShareSuc
        (JNIEnv *env, jclass cls, jstring shareId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetShareSuc( shareId : %s)",
            JString2String(env, shareId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SetShareSuc(&gHttpRequestManager,
                                                 JString2String(env, shareId),
                                                 &gRequestSetShareSucCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.13.提交Feedback（仅独立） ****************************************/
class RequestSubmitFeedBackCallback : public IRequestSubmitFeedBackCallback {
    void OnSubmitFeedBack(HttpSubmitFeedBackTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSubmitFeedBack( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSubmitFeedBack", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSubmitFeedBack( callback : %p, signature : %s )",
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

RequestSubmitFeedBackCallback gRequestSubmitFeedBackCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SubmitFeedBack
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSSubmitFeedBackCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SubmitFeedBack
        (JNIEnv * env, jclass cls, jstring mail, jstring msg, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SubmitFeedBack( mail : %s msg : %s)",
            JString2String(env, mail).c_str(), JString2String(env, msg).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SubmitFeedBack(&gHttpRequestManager,
                                                JString2String(env, mail),
                                                JString2String(env, msg),
                                                &gRequestSubmitFeedBackCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.14.获取个人信息（仅独立） ****************************************/
class RequestGetManBaseInfoCallback : public IRequestGetManBaseInfoCallback {
    void OnGetManBaseInfo(HttpGetManBaseInfoTask* task, bool success, int errnum, const string& errmsg, const HttpManBaseInfoItem& infoItem) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetManBaseInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        jobject jItem = getManBaseInfoItem(env, infoItem);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "L";
            signature += OTHER_MANBASEINFO_ITEM_CLASS;
            signature += ";";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetManBaseInfo", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetManBaseInfo( callback : %p, signature : %s )",
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

RequestGetManBaseInfoCallback gRequestGetManBaseInfoCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetManBaseInfo
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSGetManBaseInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetManBaseInfo
        (JNIEnv * env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetManBaseInfo( )");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetManBaseInfo(&gHttpRequestManager,
                                                &gRequestGetManBaseInfoCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.15.设置个人信息（仅独立） ****************************************/
class RequestSetManBaseInfoCallback : public IRequestSetManBaseInfoCallback {
    void OnSetManBaseInfo(HttpSetManBaseInfoTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetManBaseInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSetManBaseInfo", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetManBaseInfo( callback : %p, signature : %s )",
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

RequestSetManBaseInfoCallback gRequestSetManBaseInfoCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SetManBaseInfo
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSSetManBaseInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_SetManBaseInfo
        (JNIEnv *env, jclass cls, jstring nickName, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetManBaseInfo( nickName : %s)",
            JString2String(env, nickName).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SetManBaseInfo(&gHttpRequestManager,
                                                JString2String(env, nickName),
                                                &gRequestSetManBaseInfoCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}