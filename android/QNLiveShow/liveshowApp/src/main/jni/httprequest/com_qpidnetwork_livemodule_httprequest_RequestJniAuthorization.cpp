/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.h"
#include <httpcontroller/HttpRequestConvertEnum.h>

/*********************************** 登录接口 ****************************************/

class RequestLoginCallback : public IRequestLoginCallback{
	void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRequestLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /* turn object to java object here */
        jobject jItem = getLoginItem(env, item);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += LOGIN_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestLogin", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRequestLogin( callback : %p, signature : %s )",
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

RequestLoginCallback gRequestLoginCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    Login
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_Login
  (JNIEnv *env, jclass cls, jstring manId, jstring userSid, jstring deviceId, jstring model, jstring manufacturer,  jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Login( manId : %s, userSid : %s )",
            JString2String(env, manId).c_str(), JString2String(env, userSid).c_str());
    jlong taskId = -1;


	LSLoginSidType sidType = LSLOGINSIDTYPE_LSLOGIN;
		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Login( manId : %s, userSid : %s  sidType:%d)",
                JString2String(env, manId).c_str(), JString2String(env, userSid).c_str(),  sidType);
    taskId = gHttpRequestController.Login(&gHttpRequestManager,
    									JString2String(env, manId),
                                        JString2String(env, userSid),
                                        JString2String(env, deviceId),
                                        JString2String(env, model),
                                        JString2String(env, manufacturer),
										sidType,
                                        &gRequestLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 注销  ****************************************/

class RequestLogoutCallback : public IRequestLogoutCallback{
	void OnLogout(HttpLogoutTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnLogout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnLogout( callback : %p, signature : %s )",
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

RequestLogoutCallback gRequestLogoutCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    Logout
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_Logout
  (JNIEnv *env, jclass cls, jobject callback){

    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Logout()");
    jlong taskId = -1;
    taskId = gHttpRequestController.Logout(&gHttpRequestManager,
                                        &gRequestLogoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 上传push tokenId  ****************************************/

class RequestUpdateTokenIdCallback : public IRequestUpdateTokenIdCallback{
	void OnUpdateTokenId(HttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnUpdateTokenId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUpdateTokenId( callback : %p, signature : %s )",
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

RequestUpdateTokenIdCallback gRequestUpdateTokenIdCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization
 * Method:    UploadPushTokenId
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_UploadPushTokenId
  (JNIEnv *env, jclass cls, jstring tokenId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UploadPushTokenId( tokenId : %s )",
            JString2String(env, tokenId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.UpdateTokenId(&gHttpRequestManager,
                                        JString2String(env, tokenId),
                                        &gRequestUpdateTokenIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.13.可登录的站点列表  ****************************************/

class RequestGetValidsiteIdCallback : public IRequestGetValidsiteIdCallback {
    void OnGetValidsiteId(HttpGetValidsiteIdTask* task, bool success, const string& errnum, const string& errmsg, const HttpValidSiteIdList& SiteIdList) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetValidsiteId( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        jobjectArray  jItemArray = NULL;
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
                   signature += "[L";
                   signature += LSVALIDSITEID_ITEM_CLASS;
                   signature += ";";
                   signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetValidSiteId", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetValidsiteId( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jItemArray = getValidSiteIdListArray(env, SiteIdList);
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray);
                env->DeleteLocalRef(jerrmsg);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        if(jItemArray != NULL){
            env->DeleteLocalRef(jItemArray);
        }

        ReleaseEnv(isAttachThread);
        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetValidsiteId(end)");
    }
};

RequestGetValidsiteIdCallback gRequestGetValidsiteIdCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_GetValidSiteId
        (JNIEnv *env, jclass cls, jstring email, jstring password, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetValidSiteId( email : %s password : %s)",
            JString2String(env, email).c_str(), JString2String(env, password).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetValidsiteId(&gDomainRequestManager,
                                                  JString2String(env, email),
                                                  JString2String(env, password),
                                                  &gRequestGetValidsiteIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.14.添加App token  ****************************************/

class RequestAddTokenCallback : public IRequestAddTokenCallback {
    void OnAddToken(HttpAddTokenTask* task, bool success, const string& errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddToken( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        jobjectArray  jItemArray = NULL;
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddToken( callback : %p, signature : %s )",
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

RequestAddTokenCallback gRequestAddTokenCallback;
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_AddToken
        (JNIEnv *env, jclass cls, jstring token, jstring appId, jstring deviceId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AddToken( token : %s appId : %s deviceId : %s)",
            JString2String(env, token).c_str(), JString2String(env, appId).c_str(), JString2String(env, deviceId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.AddToken(&gDomainRequestManager,
                                             JString2String(env, token),
                                             JString2String(env, appId),
                                             JString2String(env, deviceId),
                                             &gRequestAddTokenCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.15.销毁App token  ****************************************/

class RequestDestroyTokenCallback : public IRequestDestroyTokenCallback {
    void OnDestroyToken(HttpDestroyTokenTask* task, bool success, const string& errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDestroyToken( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        jobjectArray  jItemArray = NULL;
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDestroyToken( callback : %p, signature : %s )",
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

RequestDestroyTokenCallback gRequestDestroyTokenCallback;
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_DestroyToken
        (JNIEnv *env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::DestroyToken()");
    jlong taskId = -1;
    taskId = gHttpRequestController.DestroyToken(&gDomainRequestManager,
                                             &gRequestDestroyTokenCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.16.找回密码  ****************************************/

class RequestFindPasswordCallback : public IRequestFindPasswordCallback {
    void OnFindPassword(HttpFindPasswordTask* task, bool success, const string& errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnFindPassword( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        jobjectArray  jItemArray = NULL;
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnFindPassword( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jerrnum = env->NewStringUTF(errnum.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jerrnum);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestFindPasswordCallback gRequestFindPasswordCallback;
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_FindPassword
        (JNIEnv *env, jclass cls, jstring sendMail, jstring checkCode, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::FindPassword( sendMail : %s checkCode : %s)", JString2String(env, sendMail).c_str(), JString2String(env, checkCode).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.FindPassword(&gHttpRequestManager,
                                                 JString2String(env, sendMail),
                                                 JString2String(env, checkCode),
                                                 &gRequestFindPasswordCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.17.修改密码  ****************************************/

class RequestChangePasswordCallback : public IRequestChangePasswordCallback {
    void OnChangePassword(HttpChangePasswordTask* task, bool success, const string& errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnChangePassword( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        jobjectArray  jItemArray = NULL;
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnChangePassword( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jerrnum = env->NewStringUTF(errnum.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jerrnum);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestChangePasswordCallback gRequestChangePasswordCallback;
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_ChangePassword
        (JNIEnv *env, jclass cls, jstring passwordNew, jstring passwordOld, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::ChangePassword( passwordNew : %s passwordOld : %s)", JString2String(env, passwordNew).c_str(), JString2String(env, passwordOld).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ChangePassword(&gDomainRequestManager,
                                                 JString2String(env, passwordNew),
                                                 JString2String(env, passwordOld),
                                                 &gRequestChangePasswordCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.18.token登录认证  ****************************************/

class RequestDoLoginCallback : public IRequestDoLoginCallback {
    void OnDoLogin(HttpDoLoginTask* task, bool success, const string& errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDoLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDoLogin( callback : %p, signature : %s )",
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

RequestDoLoginCallback gRequestDoLoginCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_DoLogin
        (JNIEnv *env, jclass cls, jstring token, jstring memberId, jstring deviceId, jstring versioncode, jstring model, jstring manufacturer, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::TokenLogin( token : %s memberId : %s deviceId : %s versioncode : %s model : %s manufacturer : %s)",
            JString2String(env, token).c_str(),
            JString2String(env, memberId).c_str(),
            JString2String(env, deviceId).c_str(),
            JString2String(env, versioncode).c_str(),
            JString2String(env, model).c_str(),
            JString2String(env, manufacturer).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.DoLogin(&gDomainRequestManager,
                                                   JString2String(env, token),
                                                   JString2String(env, memberId),
                                                   JString2String(env, deviceId),
                                                   JString2String(env, versioncode),
                                                   JString2String(env, model),
                                                   JString2String(env, manufacturer),
                                                   &gRequestDoLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 2.19.获取认证token  ****************************************/

class RequestGetTokenCallback : public IRequestGetTokenCallback {
    void OnGetToken(HttpGetTokenTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetToken( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "Ljava/lang/String;Ljava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestSid", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnTokenLogin( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jmemberId = env->NewStringUTF(memberId.c_str());
                jstring jsid = env->NewStringUTF(sid.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jmemberId, jsid);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jmemberId);
                env->DeleteLocalRef(jsid);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestGetTokenCallback gRequestGetTokenCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_GetAuthToken
        (JNIEnv *env, jclass cls, jint siteId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAuthToken(siteId : %d)",
            siteId);
    jlong taskId = -1;
    string strUrl = "/app?siteid=";
    taskId = gHttpRequestController.GetToken(&gHttpRequestManager,
                                             strUrl,
                                             (HTTP_OTHER_SITE_TYPE)siteId,
                                             &gRequestGetTokenCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.20.帐号密码登录  ****************************************/

class RequestPasswordLoginCallback : public IRequestPasswordLoginCallback {
    void OnPasswordLogin(HttpPasswordLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnPasswordLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "Ljava/lang/String;Ljava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestSid", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnTokenLogin( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jmemberId = env->NewStringUTF(memberId.c_str());
                jstring jsid = env->NewStringUTF(sid.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jmemberId, jsid);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jmemberId);
                env->DeleteLocalRef(jsid);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestPasswordLoginCallback gRequestPasswordLoginCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_PasswordLogin
        (JNIEnv *env, jclass cls, jstring email, jstring password, jstring authcode, jstring afDeviceId, jstring gaid, jstring deviceId, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::PasswordLogin(email : %s password : %s authcode : %s afDeviceId : %s gaid : %s deviceId : %s)",
            JString2String(env, email).c_str(),
            JString2String(env, password).c_str(),
            JString2String(env, authcode).c_str(),
            JString2String(env, afDeviceId).c_str(),
            JString2String(env, gaid).c_str(),
            JString2String(env, deviceId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.PasswordLogin(&gHttpRequestManager,
                                               JString2String(env, email),
                                               JString2String(env, password),
                                               JString2String(env, authcode),
                                                HTTP_OTHER_SITE_LIVE,
                                                JString2String(env, afDeviceId),
                                                JString2String(env, gaid),
                                                JString2String(env, deviceId),
                                               &gRequestPasswordLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 2.21.token登录  ****************************************/

class RequestTokenLoginCallback : public IRequestTokenLoginCallback {
    void OnTokenLogin(HttpTokenLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnTokenLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "Ljava/lang/String;Ljava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequestSid", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnTokenLogin( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jmemberId = env->NewStringUTF(memberId.c_str());
                jstring jsid = env->NewStringUTF(sid.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jmemberId, jsid);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jmemberId);
                env->DeleteLocalRef(jsid);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestTokenLoginCallback gRequestTokenLoginCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_TokenLogin
        (JNIEnv *env, jclass cls, jstring memberId, jstring sid, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::TokenLogin(memberId : %s sid : %s )",
            JString2String(env, memberId).c_str(),
            JString2String(env, sid).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.TokenLogin(&gHttpRequestManager,
                                            JString2String(env, memberId),
                                            JString2String(env, sid),
                                            &gRequestTokenLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.22.获取验证码  ****************************************/

class RequestGetValidateCodeCallback : public IRequestGetValidateCodeCallback {
    void OnGetValidateCode(HttpGetValidateCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetValidateCode( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        jbyteArray byteArray = env->NewByteArray(len);
        if( byteArray != NULL ) {
            env->SetByteArrayRegion(byteArray, 0, len, (const jbyte*) data);
        }
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += "[B";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "OnGetValidateCode", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetValidateCode( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, byteArray);
                env->DeleteLocalRef(jerrmsg);
            }
        }

        if( byteArray != NULL ) {
            env->DeleteLocalRef(byteArray);
        }

        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }


        ReleaseEnv(isAttachThread);
    }
};

RequestGetValidateCodeCallback gRequestGetValidateCodeCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_GetValidateCode
        (JNIEnv *env, jclass cls, jint validateCodeType, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetValidateCode(validateCodeType:%d)", validateCodeType);
    jlong taskId = -1;
    LSValidateCodeType codeType = IntToLSValidateCodeType(validateCodeType);
    taskId = gHttpRequestController.GetValidateCode(&gHttpRequestManager,
                                                    codeType,
                                                    &gRequestGetValidateCodeCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.23.提交用户头像  ****************************************/
class RequestUploadUserPhotoCallback : public IRequestUploadUserPhotoCallback {
    void OnUploadUserPhoto(HttpUploadUserPhotoTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUploadUserPhoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;";
            signature += ")V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUploadUserPhoto( callback : %p, signature : %s )",
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

RequestUploadUserPhotoCallback gRequestUploadUserPhotoCallback;

/*
 * Class:     com_qpidnetwork_request_RequestJniAuthorization
 * Method:    UploadUserPhoto
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/request/OnRequestCommonCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization_UploadUserPhoto
        (JNIEnv *env, jclass cls, jstring photoName, jobject callback) {

       FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UploadUserPhoto(photoName:%d)", JString2String(env, photoName).c_str());
       jlong taskId = -1;
       taskId = gHttpRequestController.UploadUserPhoto(&gHttpRequestManager,
                                                       JString2String(env, photoName),
                                                       &gRequestUploadUserPhotoCallback);

       jobject obj = env->NewGlobalRef(callback);
       putCallbackIntoMap(taskId, obj);

       return taskId;
}