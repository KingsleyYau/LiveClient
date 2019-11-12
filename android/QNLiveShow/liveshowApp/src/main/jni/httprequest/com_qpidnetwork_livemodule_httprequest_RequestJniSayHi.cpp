/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniSayHi.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniSayHi.h"

/*********************************** 14.1.获取发送SayHi的主题和文本信息（用于观众端获取发送SayHi的主题和文本信息）  ****************************************/

class RequestResourceConfigCallback : public IRequestResourceConfigCallback {
	void OnResourceConfig(HttpResourceConfigTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiResourceConfigItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnResourceConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getSayHiResourceConfigItem(env, item);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHIRESOURCECONFIG_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetSayHiResourceConfig", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnResourceConfig( callback : %p, signature : %s )",
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

RequestResourceConfigCallback gRequestResourceConfigCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    GetSayHiResourceConfig
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetSayHiResourceConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_GetSayHiResourceConfig
  (JNIEnv *env, jclass cls, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetSayHiResourceConfig()");
    jlong taskId = -1;
    taskId = gHttpRequestController.SayHiConfig(&gHttpRequestManager,
                                        &gRequestResourceConfigCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.2.获取可发Say Hi的主播列表  ****************************************/

class RequestGetSayHiAnchorListCallback : public IRequestGetSayHiAnchorListCallback {
	void OnGetSayHiAnchorList(HttpGetSayHiAnchorListTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiAnchorList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetSayHiAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getSayHiAnchorListArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += SAYHI_SAYHIRECOMMENDANCHOR_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetSayHiAnchorList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetSayHiAnchorList( callback : %p, signature : %s )",
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

RequestGetSayHiAnchorListCallback gRequestGetSayHiAnchorListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    GetSayHiAnchorList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetSayHiAnchorListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_GetSayHiAnchorList
  (JNIEnv *env, jclass cls, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetSayHiAnchorList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetSayHiAnchorList(&gHttpRequestManager,
                                        &gRequestGetSayHiAnchorListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.3.检测能否对指定主播发送SayHi（用于检测能否对指定主播发送SayHi）  ****************************************/

class RequestIsCanSendSayHiCallback : public IRequestIsCanSendSayHiCallback {
	void OnIsCanSendSayHi(HttpIsCanSendSayHiTask* task, bool success, int errnum, const string& errmsg, bool isCanSend) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnIsCanSendSayHi( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "Z";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onIsCanSendSayHi", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnIsCanSendSayHi( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, isCanSend);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestIsCanSendSayHiCallback gRequestIsCanSendSayHiCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    IsCanSendSayHi
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnIsCanSendSayHiCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_IsCanSendSayHi
  (JNIEnv *env, jclass cls, jstring anchorId, jobject callback){
    string janchorId = JString2String(env, anchorId);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::IsCanSendSayHi()");
    jlong taskId = -1;
    taskId = gHttpRequestController.IsCanSendSayHi(&gHttpRequestManager,
                                                    janchorId,
                                                    &gRequestIsCanSendSayHiCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.4.发送sayHi  ****************************************/

jobject getSayHiSendInfoItem(JNIEnv *env, bool success, int errnum,  const string& sayHiId, const string& sayHiOrLoiId, bool isFollow, OnLineStatus onlineStatus) {
	jobject jItem = NULL;
	jclass jItemCls = GetJClass(env, SAYHI_SAYHISENDINFO_ITEM_CLASS);
	if (NULL != jItemCls) {
		string	signature = "(";
		        signature += "ZLjava/lang/String;I";
		        signature += "Ljava/lang/String;Z";
		        signature += ")V";
		jmethodID init = env->GetMethodID(jItemCls, "<init>", signature.c_str());
		if (NULL != init) {
		    string strSayHiId = sayHiId;
		    string strLoiId = "";
		    HTTP_LCC_ERR_TYPE errCode = (HTTP_LCC_ERR_TYPE)errnum;
		    if (errCode == HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI) {
		        strSayHiId = sayHiOrLoiId;
		    } else if (errCode == HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI) {
		        strLoiId = sayHiOrLoiId;
		    }
			jstring jsayHiId = env->NewStringUTF(strSayHiId.c_str());
        	jstring jloiId = env->NewStringUTF(strLoiId.c_str());
        	int jonlineStatus = AnchorOnlineStatusToInt(onlineStatus);
			jItem = env->NewObject(jItemCls, init,
								   success, jsayHiId, jonlineStatus, jloiId, isFollow);
			env->DeleteLocalRef(jsayHiId);
            env->DeleteLocalRef(jloiId);
		}
	}
    if (NULL != jItemCls) {
        env->DeleteLocalRef(jItemCls);
    }

	return jItem;
}

class RequestSendSayHiCallback : public IRequestSendSayHiCallback {
	void OnSendSayHi(HttpSendSayHiTask* task, bool success, int errnum, const string& errmsg, const string& sayHiId, const string& sayHiOrLoiId, bool isFollow, OnLineStatus onlineStatus) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendSayHi( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject itemObj = getSayHiSendInfoItem(env, success, errnum, sayHiId, sayHiOrLoiId, isFollow, onlineStatus);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHISENDINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSendSayHi", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendSayHi( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, itemObj);
				env->DeleteLocalRef(jerrmsg);
			}
		}

        if (NULL != itemObj) {
            env->DeleteLocalRef(itemObj);
        }

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestSendSayHiCallback gRequestSendSayHiCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    SendSayHi
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnSendSayHiCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_SendSayHi
  (JNIEnv *env, jclass cls, jstring anchorId, jstring themeId, jstring textId, jobject callback){
   string janchorId = JString2String(env, anchorId);
   string jthemeId = JString2String(env, themeId);
   string jtextId = JString2String(env, textId);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SendSayHi(anchorId：%s, themeId：%s, textId：%s)",
            janchorId.c_str(), jthemeId.c_str(), jtextId.c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SendSayHi(&gHttpRequestManager,
    									janchorId,
    									jthemeId,
    									jtextId,
                                        &gRequestSendSayHiCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.5.获取Say Hi的All列表  ****************************************/

class RequestGetAllSayHiListCallback : public IRequestGetAllSayHiListCallback {
	void OnGetAllSayHiList(HttpGetAllSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpAllSayHiListItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetAllSayHiList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItemObj = getSayHiAllListInfoItem(env, item);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHIALLLISTINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetAllSayHiList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetAllSayHiList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemObj);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItemObj != NULL){
			env->DeleteLocalRef(jItemObj);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetAllSayHiListCallback gRequestGetAllSayHiListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    GetAllGiftList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_GetAllSayHiList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetAllGiftList(start : %d, step : %d)", start, step);
    jlong taskId = -1;
    taskId = gHttpRequestController.GetAllSayHiList(&gHttpRequestManager,
                                            start,
                                            step,
                                        &gRequestGetAllSayHiListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.6.获取SayHi的Response列表  ****************************************/

class RequestGetResponseSayHiListCallback : public IRequestGetResponseSayHiListCallback {
	void OnGetResponseSayHiList(HttpGetResponseSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpResponseSayHiListItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetResponseSayHiList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItemArray = getSayHiResponseListInfoItem(env, item);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHIRESPONSELISTINFO_ITEM_CLASS;
			signature += ";)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetResponseSayHiList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetResponseSayHiList( callback : %p, signature : %s )",
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

RequestGetResponseSayHiListCallback gRequestGetResponseSayHiListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    GetResponseSayHiList
 * Signature: (IIILcom/qpidnetwork/livemodule/httprequest/OnGetResponseSayHiListCallbackk;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_GetResponseSayHiList
  (JNIEnv *env, jclass cls, jint start, jint step, jint type, jobject callback){

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetResponseSayHiList(start : %d, step : %d, type : %d)",
            start, step, type);
    jlong taskId = -1;
    LSSayHiListType jtype = IntToLSSayHiListType(type);
    taskId = gHttpRequestController.GetResponseSayHiList(&gHttpRequestManager,
    									jtype,
    									start,
    									step,
                                        &gRequestGetResponseSayHiListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.7.获取SayHi详情  ****************************************/

class RequestSayHiDetailCallback : public IRequestSayHiDetailCallback {
	void OnSayHiDetail(HttpSayHiDetailTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI:::OnSayHiDetail( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getSayHiDetailItem(env, item);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHIDETAIL_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetSayDetail", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSayHiDetail( callback : %p, signature : %s )",
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

RequestSayHiDetailCallback gRequestSayHiDetailCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    GetSayHiDetail
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnGetSayDetailCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_GetSayHiDetail
  (JNIEnv *env, jclass cls, jstring sayHiId, jint type, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetSayHiDetail( type : %d, sayHiId : %s )",
            type, JString2String(env, sayHiId).c_str());
    jlong taskId = -1;
    LSSayHiDetailType jtype = IntToLSSayHiDetailType(type);
    taskId = gHttpRequestController.SayHiDetail(&gHttpRequestManager,
                                        jtype,
    									JString2String(env, sayHiId),
                                        &gRequestSayHiDetailCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 14.8.购买阅读SayHi回复详情 （用于购买阅读SayHi回复）  ****************************************/

class RequestReadResponseCallback : public IRequestReadResponseCallback {
	void OnReadResponse(HttpReadResponseTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem::ResponseSayHiDetailItem& responseItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnReadResponse( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItemObj = getSayHiDetailResponseItem(env, responseItem);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += SAYHI_SAYHIDETAILRESPONSELIST_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onReadSayHiResponse", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnReadResponse( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemObj);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(jItemObj != NULL){
			env->DeleteLocalRef(jItemObj);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestReadResponseCallback gRequestReadResponseCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniSayHi
 * Method:    ReadSayHiResponse
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnReadSayHiResponseCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniSayHi_ReadSayHiResponse
  (JNIEnv *env, jclass cls, jstring sayHiId, jstring responseId, jobject callback){

	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::ReadSayHiResponse(sayHiId : %s, responseId : %s)"
	                    , JString2String(env, sayHiId).c_str()
	                    , JString2String(env, responseId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ReadResponse(&gHttpRequestManager,
                                        JString2String(env, sayHiId),
                                        JString2String(env, responseId),
                                        &gRequestReadResponseCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

