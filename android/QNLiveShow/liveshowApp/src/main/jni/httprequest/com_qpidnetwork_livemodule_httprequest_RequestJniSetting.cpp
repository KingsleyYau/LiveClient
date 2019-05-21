/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniSetting.cpp
 *
 *  Created on: 2018-5-7
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniSetting.h"

/*********************************** 11.1.获取推送设置  ****************************************/

class RequestGetPushConfigCallback : public IRequestGetPushConfigCallback{
	void OnGetPushConfig(HttpGetPushConfigTask* task, bool success, int errnum, const string& errmsg, const HttpAppPushConfigItem& appPushItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPushConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "ZZ";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetPushConfig", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPushConfig( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, appPushItem.isPriMsgAppPush, appPushItem.isMailAppPush);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetPushConfigCallback gRequestGetPushConfigCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSetting_GetPushConfig
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPushConfig( )");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetPushConfig(&gHttpRequestManager,
                                                            &gRequestGetPushConfigCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 11.2.修改推送设置  ****************************************/

class RequestSetPushConfigCallback : public IRequestSetPushConfigCallback{
	void OnSetPushConfig(HttpSetPushConfigTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetPushConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetPushConfig( callback : %p, signature : %s )",
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

RequestSetPushConfigCallback gRequestSetPushConfigCallbackk;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSetting_SetPushConfig
		(JNIEnv *env, jclass cls, jboolean isPriMsgAppPush, jboolean isMailAppPush, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetPushConfig(isPriMsgAppPush : %d,  isMailAppPush :%d)", isPriMsgAppPush, isMailAppPush);
    jlong taskId = -1;
    taskId = gHttpRequestController.SetPushConfig(&gHttpRequestManager,
                                                  isPriMsgAppPush,
                                                  isMailAppPush,
                                                  false,
                                                  &gRequestSetPushConfigCallbackk);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
