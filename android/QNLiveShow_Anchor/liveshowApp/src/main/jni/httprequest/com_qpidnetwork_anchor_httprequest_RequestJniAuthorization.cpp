/*
 * com_qpidnetwork_anchor_httprequest_RequestJniAuthorization.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_anchor_httprequest_RequestJniAuthorization.h"

/*********************************** 登录接口 ****************************************/

class RequestZBLoginCallback : public IRequestZBLoginCallback{
	void OnZBLogin(ZBHttpLoginTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLoginItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onRequestLogin( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /* turn object to java object here */
        jobject jItem = getLoginItem(env, item);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

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

RequestZBLoginCallback gRequestZBLoginCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniAuthorization
 * Method:    Login
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLoginCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniAuthorization_Login
  (JNIEnv *env, jclass cls, jstring anchorId, jstring password, jstring code, jstring deviceId, jstring model, jstring manufacturer, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::Login( anchorId : %s, password : %s, code : %s )",
            JString2String(env, anchorId).c_str(), JString2String(env, password).c_str(), JString2String(env, code).c_str());
    jlong taskId = -1;

    taskId = gHttpRequestController.ZBLogin(&gHttpRequestManager,
    									JString2String(env, anchorId),
                                        JString2String(env, password),
										JString2String(env, code),
                                        JString2String(env, deviceId),
                                        JString2String(env, model),
                                        JString2String(env, manufacturer),
                                        &gRequestZBLoginCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.2.上传push tokenId  ****************************************/

class RequestZBUpdateTokenIdCallback : public IRequestZBUpdateTokenIdCallback {
    void OnZBUpdateTokenId(ZBHttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::ZBHttpUpdateTokenIdTask( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
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

RequestZBUpdateTokenIdCallback gRequestZBUpdateTokenIdCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniAuthorization
 * Method:    UploadPushTokenId
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniAuthorization_UploadPushTokenId
        (JNIEnv *env, jclass cls, jstring tokenId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UploadPushTokenId( tokenId : %s )",
            JString2String(env, tokenId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBUpdateTokenId(&gHttpRequestManager,
                                                  JString2String(env, tokenId),
                                                  &gRequestZBUpdateTokenIdCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 2.3.获取验证码  ****************************************/

class RequestZBGetVerificationCodeCallback : public IRequestZBGetVerificationCodeCallback {
    void OnZBGetVerificationCode(ZBHttpGetVerificationCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::::OnGetVerificationCode( success : %s, task : %p,  len : %d, isAttachThread:%d )", success?"true":"false", task, len, isAttachThread);

        jbyteArray byteArray = env->NewByteArray(len);
        if( byteArray != NULL ) {
            env->SetByteArrayRegion(byteArray, 0, len, (const jbyte*) data);
        }
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;[B)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetVerificationCode", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetVerificationCode( callback : %p, signature : %s )",
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

RequestZBGetVerificationCodeCallback gRequestZBGetVerificationCodeCallbackk;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniAuthorization
 * Method:    LSGetVerificationCode
 * Signature: (IZLcom/qpidnetwork/livemodule/httprequest/OnRequestGetVerificationCodeCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniAuthorization_LSGetVerificationCode
        (JNIEnv * env, jclass cls, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::LSGetVerificationCode( ) ");
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetVerificationCode(&gHttpRequestManager,
                                                        &gRequestZBGetVerificationCodeCallbackk);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
