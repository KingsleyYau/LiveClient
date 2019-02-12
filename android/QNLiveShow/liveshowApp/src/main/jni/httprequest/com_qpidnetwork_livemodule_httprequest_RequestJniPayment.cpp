/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniPayment.cpp
 *
 *  Created on: 2018-5-7
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniPayment.h"

/*********************************** 7.7.获取h5买点页面URL（仅Android）  ****************************************/

class RequestMobilePayGotoCallback : public IRequestMobilePayGotoCallback{
	void OnMobilePayGoto(HttpMobilePayGotoTask* task, bool success, int errnum, const string& errmsg, const string& redirect) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnMobilePayGoto( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "Ljava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onMobilePayGoto", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPushConfig( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jredirect = env->NewStringUTF(redirect.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jredirect);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jredirect);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestMobilePayGotoCallback gRequestMobilePayGotoCallback;

JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPayment_MobilePayGoto
		(JNIEnv *env, jclass cls, jint orderType, jstring clickFrom, jstring numberId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::MobilePayGoto( orderType:%d)", orderType);
	string strUrl = "/app?siteid=";
	HTTP_OTHER_SITE_TYPE siteId = HTTP_OTHER_SITE_PAYMENT;
	LSOrderType type = IntToLSOrderType(orderType);
    jlong taskId = -1;
    taskId = gHttpRequestController.MobilePayGoto(&gHttpRequestManager,
												  strUrl,
												  siteId,
												  type,
												  JString2String(env, clickFrom),
												  JString2String(env, numberId),
                                                  &gRequestMobilePayGotoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
