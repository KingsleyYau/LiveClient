/*
 * com_qpidnetwork_livemodule_httprequest_RequstJniSchedule.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_livemodule_httprequest_RequstJniSchedule.h"

/*********************************** 4.1.获取预约邀请列表  ****************************************/

class RequestManHandleBookingListCallback : public IRequestManHandleBookingListCallback{
	void OnManHandleBookingList(HttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const HttpBookingInviteListItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetScheduleInviteList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getBookInviteArray(env, item.list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;I";
			signature += "[L";
			signature += BOOK_INVITE_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetScheduleInviteList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI:::onGetScheduleInviteList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, item.total, jItemArray);
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

RequestManHandleBookingListCallback gRequestManHandleBookingListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    GetScheduleInviteList
 * Signature: (IIILcom/qpidnetwork/livemodule/httprequest/OnGetScheduleInviteListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_GetScheduleInviteList
  (JNIEnv *env, jclass cls, jint type, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetScheduleInviteList( type : %d, start : %d, step : %d )",
			type, start, step);
    jlong taskId = -1;
    BookingListType bookingListType = IntToBookInviteListType(type);
    taskId = gHttpRequestController.ManHandleBookingList(&gHttpRequestManager,
    									bookingListType,
                                        start,
                                        step,
                                        &gRequestManHandleBookingListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.2.观众处理预约邀请  ****************************************/

class RequestHandleBookingCallback : public IRequestHandleBookingCallback{
	void OnHandleBooking(HttpHandleBookingTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnHandleBooking( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnHandleBooking( callback : %p, signature : %s )",
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

RequestHandleBookingCallback gRequestHandleBookingCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    HandleScheduledInvite
 * Signature: (Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_HandleScheduledInvite
  (JNIEnv *env, jclass cls, jstring invitationId, jboolean isHandled, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::HandleScheduledInvite( invitationId : %s, isHandled : %d )",
			JString2String(env, invitationId).c_str(), isHandled);
    jlong taskId = -1;
    taskId = gHttpRequestController.HandleBooking(&gHttpRequestManager,
    									JString2String(env, invitationId),
    									isHandled,
                                        &gRequestHandleBookingCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 4.3.取消预约邀请  ****************************************/

class RequestSendCancelPrivateLiveInviteCallback : public IRequestSendCancelPrivateLiveInviteCallback{
	void OnSendCancelPrivateLiveInvite(HttpSendCancelPrivateLiveInviteTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelPrivateRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelPrivateRequest( callback : %p, signature : %s )",
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

RequestSendCancelPrivateLiveInviteCallback gRequestSendCancelPrivateLiveInviteCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    CancelScheduledInvite
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_CancelScheduledInvite
  (JNIEnv *env, jclass cls, jstring invitationId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CancelScheduledInvite( invitationId : %s )",
			JString2String(env, invitationId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SendCancelPrivateLiveInvite(&gHttpRequestManager,
    									JString2String(env, invitationId),
                                        &gRequestSendCancelPrivateLiveInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.4.获取预约邀请未读或待处理数量  ****************************************/

class RequestManBookingUnreadUnhandleNumCallback : public IRequestManBookingUnreadUnhandleNumCallback{
	void OnManBookingUnreadUnhandleNum(HttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg,
			const HttpBookingUnreadUnhandleNumItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnManBookingUnreadUnhandleNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;IIII)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCountOfUnreadAndPendingInvite", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnManBookingUnreadUnhandleNum( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, item.totalNoReadNum, item.pendingNoReadNum, item.scheduledNoReadNum, item.historyNoReadNum);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestManBookingUnreadUnhandleNumCallback gRequestManBookingUnreadUnhandleNumCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    GetCountOfUnreadAndPendingInvite
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetCountOfUnreadAndPendingInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_GetCountOfUnreadAndPendingInvite
  (JNIEnv *env, jclass cls, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCountOfUnreadAndPendingInvite()");
    jlong taskId = -1;
    taskId = gHttpRequestController.ManBookingUnreadUnhandleNum(&gHttpRequestManager,
    									&gRequestManBookingUnreadUnhandleNumCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.5.获取新建预约邀请信息  ****************************************/

class RequestGetCreateBookingInfoCallback : public IRequestGetCreateBookingInfoCallback{
	void OnGetCreateBookingInfo(HttpGetCreateBookingInfoTask* task, bool success, int errnum, const string& errmsg,
			const HttpGetCreateBookingInfoItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCreateBookingInfo( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = getBookInviteConfigItem(env, item);
        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += BOOK_INVITE_CONFIG_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetScheduleInviteCreateConfig", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCreateBookingInfo( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItem);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(NULL != jItem){
			env->DeleteLocalRef(jItem);
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetCreateBookingInfoCallback gRequestGetCreateBookingInfoCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    GetScheduleInviteCreateConfig
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetScheduleInviteCreateConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_GetScheduleInviteCreateConfig
  (JNIEnv *env, jclass cls, jstring anchorId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetScheduleInviteCreateConfig( anchorId : %s )",
			JString2String(env, anchorId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetCreateBookingInfo(&gHttpRequestManager,
    									JString2String(env, anchorId),
    									&gRequestGetCreateBookingInfoCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.6.新建预约邀请  ****************************************/

class RequestSendBookingRequestCallback : public IRequestSendBookingRequestCallback{
	void OnSendBookingRequest(HttpSendBookingRequestTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendBookingRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSendBookingRequest( callback : %p, signature : %s )",
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

RequestSendBookingRequestCallback gRequestSendBookingRequestCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    CreateScheduleInvite
 * Signature: (Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;IZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_CreateScheduleInvite
  (JNIEnv *env, jclass cls, jstring userId, jstring timeId, jint bookTime, jstring giftId, jint giftNum, jboolean needSms, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CreateScheduleInvite( userId : %s, timeId : %s, bookTime : %d, giftId : %s, giftNum : %d, needSms : %d )",
            JString2String(env, userId).c_str(), JString2String(env, timeId).c_str(), bookTime, JString2String(env, giftId).c_str(), giftNum, needSms);
    jlong taskId = -1;
    taskId = gHttpRequestController.SendBookingRequest(&gHttpRequestManager,
    									JString2String(env, userId),
    									JString2String(env, timeId),
    									bookTime,
    									JString2String(env, giftId),
    									giftNum,
    									needSms,
    									&gRequestSendBookingRequestCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.7.观众处理立即私密邀请  ****************************************/

class RequestAcceptInstanceInviteCallback : public IRequestAcceptInstanceInviteCallback{
	void OnAcceptInstanceInvite(HttpAcceptInstanceInviteTask* task, bool success, int errnum, const string& errmsg, const HttpAcceptInstanceInviteItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAcceptInstanceInvite( success : %s, task : %p, roomId:%s isAttachThread:%d )", success?"true":"false", task, item.roomId.c_str(), isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;I)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onAcceptInstanceInvite", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAcceptInstanceInvite( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jroomId = env->NewStringUTF(item.roomId.c_str());
				jint jroomType = LiveRoomTypeToInt(item.roomType);
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jroomId, jroomType);
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

RequestAcceptInstanceInviteCallback gRequestAcceptInstanceInviteCallback;
/*
 * Class:     com_qpidnetwork_livemodule_httprequest_AcceptInstanceInvite
 * Method:    AcceptInstanceInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnAcceptInstanceInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_AcceptInstanceInvite
  (JNIEnv *env, jclass cls, jstring inviteId, jboolean isConfirm, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AcceptInstanceInvite( inviteId : %s, isConfirm : %d )",
			JString2String(env, inviteId).c_str(), isConfirm);
    jlong taskId = -1;
    taskId = gHttpRequestController.AcceptInstanceInvite(&gHttpRequestManager,
    									JString2String(env, inviteId),
    									isConfirm,
                                        &gRequestAcceptInstanceInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;

}


