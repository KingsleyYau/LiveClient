/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg.cpp
 *
 *  Created on: 2017-6-13
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg.h"


//
///*********************************** 10.1.获取私信联系人列表  ****************************************/
//class RequestGetPrivateMsgFriendListCallback : public IRequestGetPrivateMsgFriendListCallback {
//	void OnGetPrivateMsgFriendList(HttpGetPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {
//		JNIEnv* env = NULL;
//		bool isAttachThread = false;
//		GetEnv(&env, &isAttachThread);
//
//		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::HttpGetPrivateMsgFriendListTask( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);
//
//		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
//		/*callback object*/
//		jobject callBackObject = getCallbackObjectByTask((long)task);
//		if(callBackObject != NULL){
////			jclass callBackCls = env->GetObjectClass(callBackObject);
////			string signature = "(ZILjava/lang/String;";
////			signature += "L";
////			signature += OTHER_MAINUNREADNUM_ITEM_CLASS;
////			signature += ";";
////			signature += ")V";
////			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetMainUnreadNum", signature.c_str());
////			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetMainUnreadNum( callback : %p, signature : %s )",
////					callbackMethod, signature.c_str());
////			if(callbackMethod != NULL){
////                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
////				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
////                env->DeleteLocalRef(jerrmsg);
////			}
//		}
//
//
//
//		if(callBackObject != NULL){
//			env->DeleteGlobalRef(callBackObject);
//		}
//
//		ReleaseEnv(isAttachThread);
//	}
//};
//RequestGetPrivateMsgFriendListCallback gRequestGetPrivateMsgFriendListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetMainUnreadNum
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetMainUnreadNumCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetPrivateMsgFriendList
		(JNIEnv *env, jclass cls, jlong callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPrivateMsgFriendList()");
	jlong taskId = -1;
    IRequestGetPrivateMsgFriendListCallback* jcallback = (IRequestGetPrivateMsgFriendListCallback*)callback;
	taskId = gHttpRequestController.GetPrivateMsgFriendList(&gHttpRequestManager, jcallback);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPrivateMsgFriendList() taskId:%lld", taskId);
//	jobject obj = env->NewGlobalRef(callback);
//	putCallbackIntoMap(taskId, obj);

	return taskId;
}



///***********************************10.2.获取私信Follow联系人列表  ****************************************/
//class RequestGetFollowPrivateMsgFriendListCallback : public IRequestGetFollowPrivateMsgFriendListCallback {
//	void OnGetFollowPrivateMsgFriendList(HttpGetFollowPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) {
//		JNIEnv* env = NULL;
//		bool isAttachThread = false;
//		GetEnv(&env, &isAttachThread);
//
//		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetFollowPrivateMsgFriendList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);
//
//		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
//		/*callback object*/
//		jobject callBackObject = getCallbackObjectByTask((long)task);
//		if(callBackObject != NULL){
////			jclass callBackCls = env->GetObjectClass(callBackObject);
////			string signature = "(ZILjava/lang/String;";
////			signature += "L";
////			signature += OTHER_USERINFO_ITEM_CLASS;
////			signature += ";";
////			signature += ")V";
////			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetUserInfo", signature.c_str());
////			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetUserInfo( callback : %p, signature : %s )",
////					callbackMethod, signature.c_str());
////			if(callbackMethod != NULL){
////				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
////				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
////				env->DeleteLocalRef(jerrmsg);
////			}
//		}
//
//
//		if(callBackObject != NULL){
//			env->DeleteGlobalRef(callBackObject);
//		}
//
//		ReleaseEnv(isAttachThread);
//	}
//};

//RequestGetFollowPrivateMsgFriendListCallback gRequestGetFollowPrivateMsgFriendListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    GetUserInfo
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnGetUserInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetFollowPrivateMsgFriendList
		(JNIEnv *env, jclass cls, jlong callback) {
	jlong taskId = -1;
    IRequestGetFollowPrivateMsgFriendListCallback* jcallback = (IRequestGetFollowPrivateMsgFriendListCallback*)callback;
	taskId = gHttpRequestController.GetFollowPrivateMsgFriendList(&gHttpRequestManager, jcallback
	);
//	jobject obj = env->NewGlobalRef(callback);
//	putCallbackIntoMap(taskId, obj);

	return taskId;

}

///*********************************** 10.3.获取私信消息列表  ****************************************/
//class RequestGetPrivateMsgHistoryByIdCallback : public IRequestGetPrivateMsgHistoryByIdCallback {
//	void OnGetPrivateMsgHistoryById(HttpGetPrivateMsgHistoryByIdTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) {
//		JNIEnv* env = NULL;
//		bool isAttachThread = false;
//		GetEnv(&env, &isAttachThread);
//
//		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetPrivateMsgHistoryById( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);
//
//		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
//		/*callback object*/
//		jobject callBackObject = getCallbackObjectByTask((long)task);
//		if(callBackObject != NULL){
////			jclass callBackCls = env->GetObjectClass(callBackObject);
////			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
////			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onBanner", signature.c_str());
////			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnBanner( callback : %p, signature : %s )",
////					callbackMethod, signature.c_str());
////			if(callbackMethod != NULL){
////				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
////				jstring jbannerImg = env->NewStringUTF(bannerImg.c_str());
////				jstring jbannerLink = env->NewStringUTF(bannerLink.c_str());
////				jstring jbannerName = env->NewStringUTF(bannerName.c_str());
////				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jbannerImg, jbannerLink, jbannerName);
////				env->DeleteLocalRef(jerrmsg);
////				env->DeleteLocalRef(jbannerImg);
////				env->DeleteLocalRef(jbannerLink);
////				env->DeleteLocalRef(jbannerName);
////			}
//		}
//
//		if(callBackObject != NULL){
//			env->DeleteGlobalRef(callBackObject);
//		}
//
//		ReleaseEnv(isAttachThread);
//	}
//};
//RequestGetPrivateMsgHistoryByIdCallback gRequestGetPrivateMsgHistoryByIdCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    Banner
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_GetPrivateMsgHistoryById
		(JNIEnv *env, jclass cls, jstring toId, jstring startMsgId, jint order, jint limit, jint reqId, jlong callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPrivateMsgHistoryById()");
	jlong taskId = -1;
    IRequestGetPrivateMsgHistoryByIdCallback* jcallback = (IRequestGetPrivateMsgHistoryByIdCallback*)callback;
	taskId = gHttpRequestController.GetPrivateMsgHistoryById(&gHttpRequestManager,
															 JString2String(env, toId),
															 JString2String(env, startMsgId),
                                                             (PrivateMsgOrderType)order,
															 limit,
															 reqId,
															 jcallback);
//	jobject obj = env->NewGlobalRef(callback);
//	putCallbackIntoMap(taskId, obj);

	return taskId;

}

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniOther
 * Method:    SetPrivateMsgReaded
 * Signature: (Ljava/lang/String;Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPrivateMsg_SetPrivateMsgReaded
        (JNIEnv * env, jclass cls, jstring toId, jstring msgId, jlong callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetPrivateMsgReaded() begin");
    jlong taskId = -1;
    IRequestSetPrivateMsgReadedCallback* jcallback = (IRequestSetPrivateMsgReadedCallback*)callback;
    taskId = gHttpRequestController.SetPrivateMsgReaded(&gHttpRequestManager,
                                                             JString2String(env, toId),
                                                             JString2String(env, msgId),
                                                             jcallback);
//	jobject obj = env->NewGlobalRef(callback);
//	putCallbackIntoMap(taskId, obj);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetPrivateMsgReaded() end");
    return taskId;
}

