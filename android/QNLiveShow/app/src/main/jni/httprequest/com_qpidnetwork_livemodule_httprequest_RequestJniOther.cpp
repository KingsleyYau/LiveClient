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

        FileLog("httprequest", "JNI::onSynConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = getSynConfigItem(env, configItem);

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
			FileLog("httprequest", "JNI::onSynConfig( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItem);
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
    taskId = gHttpRequestController.GetConfig(&gHttpRequestManager,
                                        &gRequestGetConfigCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 6.2. 获取账号余额    ****************************************/

class RequestGetCreditCallback : public IRequestGetCreditCallback{
	void OnGetCredit(HttpGetCreditTask* task, bool success, int errnum, const string& errmsg, double credit){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetCredit( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;D)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAccountBalance", signature.c_str());
			FileLog("httprequest", "JNI::OnGetCredit( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, credit);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetCreditCallback gRequestGetCreditCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetAccountBalance
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetAccountBalanceCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniOther_GetAccountBalance
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetCredit(&gPhotoUploadRequestManager,
    									&gRequestGetCreditCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
