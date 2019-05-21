/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniHangout.cpp
 *
 *  Created on: 2018-5-7
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniHangout.h"

/*********************************** 8.1.获取可邀请多人互动的主播列表  ****************************************/

class RequestGetCanHangoutAnchorListCallback : public IRequestGetCanHangoutAnchorListCallback{
	void OnGetCanHangoutAnchorList(HttpGetCanHangoutAnchorListTask* task, bool success, int errnum, const string& errmsg, const HangoutAnchorList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCanHangoutAnchorList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getHangoutAnchorInfoArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCanHangoutAnchorListCallback", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCanHangoutAnchorList( callback : %p, signature : %s )",
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

RequestGetCanHangoutAnchorListCallback gRequestGetCanHangoutAnchorListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    GetCanHangoutAnchorList
 * Signature: (ILjava/lang/String;IILcom/qpidnetwork/livemodule/httprequest/OnGetCanHangoutAnchorListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetCanHangoutAnchorList
		(JNIEnv *env, jclass cls, jint type, jstring anchorId, jint start, jint step, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCanHangoutAnchorList( type : %d, anchor : %s, start : %d, step : %d )",
			type, JString2String(env, anchorId).c_str(), start, step);
    jlong taskId = -1;
	HangoutAnchorListType jtype = IntToHangoutAnchorListType(type);
    taskId = gHttpRequestController.GetCanHangoutAnchorList(&gHttpRequestManager,
															jtype,
															JString2String(env, anchorId),
                                                            start,
                                                            step,
                                                            &gRequestGetCanHangoutAnchorListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 8.2.发起多人互动邀请 ****************************************/

class RequestSendInvitationHangoutCallback : public IRequestSendInvitationHangoutCallback{
	void OnSendInvitationHangout(HttpSendInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& inviteId, int expire){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendInvitationHangout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "Ljava/lang/String;Ljava/lang/String;I)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSendInvitationHangout", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendInvitationHangout( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jstring jroomId = env->NewStringUTF(roomId.c_str());
                jstring jinviteId = env->NewStringUTF(inviteId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jroomId, jinviteId, expire);
                env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
                env->DeleteLocalRef(jinviteId);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestSendInvitationHangoutCallback gRequestSendInvitationHangoutCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    SendInvitationHangout
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnSendInvitationHangoutCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_SendInvitationHangout
        (JNIEnv * env, jclass cls, jstring roomId, jstring anchorId, jstring recommendId, jboolean isCreateOnly, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SendInvitationHangout( roomId : %s, anchorId : %s, recommendId :%s, isCreateOnly : %d)",
            JString2String(env, roomId).c_str(), JString2String(env, anchorId).c_str(), JString2String(env, recommendId).c_str(), isCreateOnly);
    jlong taskId = -1;
    taskId = gHttpRequestController.SendInvitationHangout(&gHttpRequestManager,
                                                          JString2String(env, roomId),
                                                          JString2String(env, anchorId),
                                                          JString2String(env, recommendId),
                                                          isCreateOnly,
                                                          &gRequestSendInvitationHangoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 8.3.取消多人互动邀请  ****************************************/

class RequestCancelInviteHangoutCallback : public IRequestCancelInviteHangoutCallback{
	void OnCancelInviteHangout(HttpCancelInviteHangoutTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelInviteHangout( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelInviteHangout( callback : %p, signature : %s )",
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

RequestCancelInviteHangoutCallback gRequestCancelInviteHangoutCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    CancelHangoutInvit
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_CancelHangoutInvit
        (JNIEnv * env, jclass cls, jstring inviteId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CancelHangoutInvit() inviteId :%s", JString2String(env, inviteId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.CancelInviteHangout(&gHttpRequestManager,
                                                       JString2String(env, inviteId),
                                                       &gRequestCancelInviteHangoutCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 8.4.获取多人互动邀请状态  ****************************************/

class RequestGetHangoutInvitStatusCallback : public IRequestGetHangoutInvitStatusCallback{
	void OnGetHangoutInvitStatus(HttpGetHangoutInvitStatusTask* task, bool success, int errnum, const string& errmsg, HangoutInviteStatus status, const string& roomId, int expire){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutInvitStatus( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "ILjava/lang/String;I";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutInvitStatus", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutInvitStatus( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                jint jstatus = HangoutInviteStatusToInt(status);
                jstring jroomId = env->NewStringUTF(roomId.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jstatus, jroomId, expire);
				env->DeleteLocalRef(jerrmsg);
                env->DeleteLocalRef(jroomId);
			}
		}



		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetHangoutInvitStatusCallback gRequestGetHangoutInvitStatusCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    GetHangoutInvitStatus
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetHangoutInvitStatusCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetHangoutInvitStatus
        (JNIEnv *env, jclass cls, jstring inviteId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutInvitStatus( inviteId : %s)",
            JString2String(env, inviteId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetHangoutInvitStatus(&gHttpRequestManager,
                                                          JString2String(env, inviteId),
                                                          &gRequestGetHangoutInvitStatusCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 8.5.同意主播敲门请求  ****************************************/

class RequestDealKnockRequestCallback : public IRequestDealKnockRequestCallback{
	void OnDealKnockRequest(HttpDealKnockRequestTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDealKnockRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnDealKnockRequest( callback : %p, signature : %s )",
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

RequestDealKnockRequestCallback gRequestDealKnockRequestCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    DealKnockRequest
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_DealKnockRequest
        (JNIEnv *env, jclass cls, jstring knockId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::DealKnockRequest() knockId;%s", JString2String(env, knockId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.DealKnockRequest(&gHttpRequestManager,
                                                     JString2String(env, knockId),
                                                     &gRequestDealKnockRequestCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 8.6.获取多人互动直播间可发送的礼物列表 ****************************************/

class RequestGetHangoutGiftListCallback : public IRequestGetHangoutGiftListCallback{
	void OnGetHangoutGiftList(HttpGetHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutGiftListItem& item) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		jobject jitem = getHangoutGiftListItem(env, item);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += HANGOUT_HANGOUGIFTLIST_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutGiftList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutGiftList( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jitem);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		if(jitem != NULL){
			env->DeleteLocalRef(jitem);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetHangoutGiftListCallback gRequestGetHangoutGiftListCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    DGetHangoutGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetHangoutGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetHangoutGiftList
		(JNIEnv *env, jclass cls, jstring roomId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutGiftList() roomId;%s", JString2String(env, roomId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.GetHangoutGiftList(&gHttpRequestManager,
													 JString2String(env, roomId),
													 &gRequestGetHangoutGiftListCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 8.7.获取Hang-out在线主播列表 ****************************************/
class RequestGetHangoutOnlineAnchorCallback : public IRequestGetHangoutOnlineAnchorCallback {
	void OnGetHangoutOnlineAnchor(HttpGetHangoutOnlineAnchorTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutList& list) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutOnlineAnchor( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		jobjectArray jItemArray = getHangoutOnlineAnchorArray(env, list);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HANGOUT_HANGOUTONLINEANCHOR_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutOnlineAnchor", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutOnlineAnchor( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
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
	}
};

RequestGetHangoutOnlineAnchorCallback gRequestGetHangoutOnlineAnchorCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    GetHangoutOnlineAnchor
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetHangoutOnlineAnchorCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetHangoutOnlineAnchor
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutOnlineAnchor()");
	jlong taskId = -1;
	taskId = gHttpRequestController.GetHangoutOnlineAnchor(&gHttpRequestManager,
													 &gRequestGetHangoutOnlineAnchorCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 8.8.获取指定主播的Hang-out好友列表 ****************************************/
class RequestGetHangoutFriendsCallback : public IRequestGetHangoutFriendsCallback {
	void OnGetHangoutFriends(HttpGetHangoutFriendsTask* task, bool success, int errnum, const string& errmsg, const string& anchorId, const HangoutAnchorList& list) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutFriends( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		jobjectArray jItemArray = getHangoutAnchorInfoArray(env, list);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HANGOUT_HANGOUTANCHORINFO_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutFriends", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutFriends( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
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
	}
};

RequestGetHangoutFriendsCallback gRequestGetHangoutFriendsCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    GetHangoutFriends
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetHangoutFriends
		(JNIEnv *env, jclass cls, jstring anchorId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutFriends() anchorId:%s", JString2String(env, anchorId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.GetHangoutFriends(&gHttpRequestManager,
													 JString2String(env, anchorId),
													 &gRequestGetHangoutFriendsCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 8.9.自动邀请Hangout直播邀請展示條件 ****************************************/
class RequestAutoInvitationHangoutLiveDisplayCallback : public IRequestAutoInvitationHangoutLiveDisplayCallback {
	void OnAutoInvitationHangoutLiveDisplay(HttpAutoInvitationHangoutLiveDisplayTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAutoInvitationHangoutLiveDisplay( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAutoInvitationHangoutLiveDisplay( callback : %p, signature : %s )",
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

RequestAutoInvitationHangoutLiveDisplayCallback gRequestAutoInvitationHangoutLiveDisplayCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    AutoInvitationHangoutLiveDisplay
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_AutoInvitationHangoutLiveDisplay
		(JNIEnv *env, jclass cls, jstring anchorId, jboolean isAuto, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AutoInvitationHangoutLiveDisplay() anchorId:%s isAuto:%d", JString2String(env, anchorId).c_str(), isAuto);
	jlong taskId = -1;
	taskId = gHttpRequestController.AutoInvitationHangoutLiveDisplay(&gHttpRequestManager,
													 JString2String(env, anchorId),
													 isAuto,
													 &gRequestAutoInvitationHangoutLiveDisplayCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 8.10.自动邀请hangout点击记录 ****************************************/
class RequestAutoInvitationClickLogCallback : public IRequestAutoInvitationClickLogCallback {
	void OnAutoInvitationClickLog(HttpAutoInvitationClickLogTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAutoInvitationClickLog( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAutoInvitationClickLog( callback : %p, signature : %s )",
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

RequestAutoInvitationClickLogCallback gRequestAutoInvitationClickLogCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    AutoInvitationHangoutLiveDisplay
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_AutoInvitationClickLog
		(JNIEnv *env, jclass cls, jstring anchorId, jboolean isAuto, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AutoInvitationClickLog() anchorId:%s isAuto:%d", JString2String(env, anchorId).c_str(), isAuto);
	jlong taskId = -1;
	taskId = gHttpRequestController.AutoInvitationClickLog(&gHttpRequestManager,
													 JString2String(env, anchorId),
													 isAuto,
													 &gRequestAutoInvitationClickLogCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 8.11.获取当前会员Hangout直播状态 ****************************************/
class RequestGetHangoutStatusCallback : public IRequestGetHangoutStatusCallback {
	void OnGetHangoutStatus(HttpGetHangoutStatusTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutStatusList& list) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutStatus( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		jobjectArray jItemArray = getHangoutStatusArray(env, list);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += HANGOUT_HANGOUTROOMSTATUS_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetHangoutStatus", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetHangoutStatus( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
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
	}
};

RequestGetHangoutStatusCallback gRequestGetHangoutStatusCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniHangout
 * Method:    GetHangoutStatus
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetHangoutStatusCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniHangout_GetHangoutStatus
		(JNIEnv *env, jclass cls, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetHangoutStatus()");
	jlong taskId = -1;
	taskId = gHttpRequestController.GetHangoutStatus(&gHttpRequestManager,
													 &gRequestGetHangoutStatusCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}