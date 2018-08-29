/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_livemodule_httprequest_RequestJniAuthorization.h"

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
  (JNIEnv *env, jclass cls, jstring manId, jstring userSid, jstring deviceId, jstring model, jstring manufacturer, jint regionId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Login( manId : %s, userSid : %s )",
            JString2String(env, manId).c_str(), JString2String(env, userSid).c_str());
    jlong taskId = -1;

	RegionIdType type = IntToRegionIdType(regionId);
    taskId = gHttpRequestController.Login(&gHttpRequestManager,
    									JString2String(env, manId),
                                        JString2String(env, userSid),
                                        JString2String(env, deviceId),
                                        JString2String(env, model),
                                        JString2String(env, manufacturer),
										type,
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

