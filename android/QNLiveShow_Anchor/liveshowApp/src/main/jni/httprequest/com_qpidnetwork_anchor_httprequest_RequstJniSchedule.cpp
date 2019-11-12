/*
 * com_qpidnetwork_anchor_httprequest_RequstJniSchedule.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include <common/command.h>
#include "com_qpidnetwork_anchor_httprequest_RequstJniSchedule.h"

/*********************************** 4.1.获取预约邀请列表  ****************************************/

class RequestZBManHandleBookingListCallback : public IRequestZBManHandleBookingListCallback {
	void OnZBManHandleBookingList(ZBHttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingInviteListItem& BookingListItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetScheduleInviteList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getBookInviteArray(env, BookingListItem.list);
		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

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
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, BookingListItem.total, jItemArray);
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

RequestZBManHandleBookingListCallback gRequestZBManHandleBookingListCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetScheduleInviteList
 * Signature: (IIILcom/qpidnetwork/livemodule/httprequest/OnGetScheduleInviteListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetScheduleInviteList
  (JNIEnv *env, jclass cls, jint type, jint start, jint step, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetScheduleInviteList( type : %d, start : %d, step : %d )",
			type, start, step);
    jlong taskId = -1;
    ZBBookingListType bookingListType = IntToBookInviteListType(type);
    taskId = gHttpRequestController.ZBManHandleBookingList(&gHttpRequestManager,
    									bookingListType,
                                        start,
                                        step,
                                        &gRequestZBManHandleBookingListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.2.主播接受预约(邀请主播接受观众发起的预约邀请)  ****************************************/

class RequestZBAcceptScheduledInviteCallback : public IRequestZBAcceptScheduledInviteCallback {
	void OnZBAcceptScheduledInvite(ZBHttpAcceptScheduledInviteTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AcceptScheduledInvite( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AcceptScheduledInvite( callback : %p, signature : %s )",
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

RequestZBAcceptScheduledInviteCallback gRequestZBAcceptScheduledInviteCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    AcceptScheduledInvite
 * Signature: (Ljava/lang/String;ZLcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_AcceptScheduledInvite
  (JNIEnv *env, jclass cls, jstring invitationId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AcceptScheduledInvite( invitationId : %s)",
			JString2String(env, invitationId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBAcceptScheduledInvite(&gHttpRequestManager,
    									JString2String(env, invitationId),
                                        &gRequestZBAcceptScheduledInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)  ****************************************/

class RequestZBRejectScheduledInviteCallback : public IRequestZBRejectScheduledInviteCallback {
	void OnZBRejectScheduledInvite(ZBHttpRejectScheduledInviteTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelPrivateRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
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

RequestZBRejectScheduledInviteCallback gRequestZBRejectScheduledInviteCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    RejectScheduledInvite
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_RejectScheduledInvite
  (JNIEnv *env, jclass cls, jstring invitationId, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CancelScheduledInvite( invitationId : %s )",
			JString2String(env, invitationId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBRejectScheduledInvite(&gHttpRequestManager,
    									JString2String(env, invitationId),
                                        &gRequestZBRejectScheduledInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.4.获取预约邀请未读或待处理数量  ****************************************/

class RequestZBGetScheduleListNoReadNumCallback : public IRequestZBGetScheduleListNoReadNumCallback {
	void OnZBGetScheduleListNoReadNum(ZBHttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingUnreadUnhandleNumItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetCountOfUnreadAndPendingInvite( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
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

RequestZBGetScheduleListNoReadNumCallback gRequestZBGetScheduleListNoReadNumCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetCountOfUnreadAndPendingInvite
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetCountOfUnreadAndPendingInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetCountOfUnreadAndPendingInvite
  (JNIEnv *env, jclass cls, jobject callback){
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCountOfUnreadAndPendingInvite()");
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetScheduleListNoReadNum(&gHttpRequestManager,
    									&gRequestZBGetScheduleListNoReadNumCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)  ****************************************/

class RequestZBGetScheduledAcceptNumCallback : public IRequestZBGetScheduledAcceptNumCallback {
    void OnZBGetScheduledAcceptNum(ZBHttpGetScheduledAcceptNumTask* task, bool success, int errnum, const string& errmsg, const int scheduledNum) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetScheduledAcceptNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;I)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetScheduledAcceptNum", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetScheduledAcceptNum( callback : %p, signature : %s )",
                    callbackMethod, signature.c_str());
            if(callbackMethod != NULL){
                jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
                env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, scheduledNum);
                env->DeleteLocalRef(jerrmsg);
            }
        }
        if(callBackObject != NULL){
            env->DeleteGlobalRef(callBackObject);
        }

        ReleaseEnv(isAttachThread);
    }
};

RequestZBGetScheduledAcceptNumCallback gRequestZBGetScheduledAcceptNumCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    GetScheduledAcceptNum
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetScheduledAcceptNum;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_GetScheduledAcceptNum
        (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetScheduledAcceptNum()");
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetScheduledAcceptNum(&gHttpRequestManager,
                                                               &gRequestZBGetScheduledAcceptNumCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 4.6.主播接受立即私密邀请(用于主播接受观众发送的立即私密邀请)  ****************************************/

class RequestZBAcceptInstanceInviteCallback : public IRequestZBAcceptInstanceInviteCallback {
	void OnZBAcceptInstanceInvite(ZBHttpAcceptInstanceInviteTask* task, bool success, int errnum, const string& errmsg, const string& roomId, ZBHttpRoomType roomType) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAcceptInstanceInvite( success : %s, task : %p, roomId:%s isAttachThread:%d )", success?"true":"false", task, roomId.c_str(), isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
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
				jstring jroomId = env->NewStringUTF(roomId.c_str());
				jint jroomType = LiveRoomTypeToInt(roomType);
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

RequestZBAcceptInstanceInviteCallback gRequestZBAcceptInstanceInviteCallback;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_AcceptInstanceInvite
 * Method:    AcceptInstanceInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnAcceptInstanceInviteCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_AcceptInstanceInvite
  (JNIEnv *env, jclass cls, jstring inviteId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::AcceptInstanceInvite( inviteId : %s )",
			JString2String(env, inviteId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBAcceptInstanceInvite(&gHttpRequestManager,
    									JString2String(env, inviteId),
                                        &gRequestZBAcceptInstanceInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;

}

/*********************************** 4.7.主播拒绝立即私密邀请(用于主播拒绝观众发送的立即私密邀请)  ****************************************/

class RequestZBRejectInstanceInviteCallback : public IRequestZBRejectInstanceInviteCallback {
    void OnZBRejectInstanceInvite(ZBHttpRejectInstanceInviteTask* task, bool success, int errnum, const string& errmsg) {
        JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRejectInstanceInvite( success : %s, task : %p,  isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
        /*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        if(callBackObject != NULL){
            jclass callBackCls = env->GetObjectClass(callBackObject);
            string signature = "(ZILjava/lang/String;)V";
            jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
            FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRejectInstanceInvite( callback : %p, signature : %s )",
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

RequestZBRejectInstanceInviteCallback gRequestZBRejectInstanceInviteCallback;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_AcceptInstanceInvite
 * Method:    RejectInstanceInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_RejectInstanceInvite
        (JNIEnv *env, jclass cls, jstring inviteId, jstring rejectReason, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::RejectInstanceInvite( inviteId : %s, rejectReason : %s )",
            JString2String(env, inviteId).c_str(), JString2String(env, rejectReason).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBRejectInstanceInvite(&gHttpRequestManager,
                                                         JString2String(env, inviteId),
                                                         JString2String(env, rejectReason),
                                                         &gRequestZBRejectInstanceInviteCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;

}

/*********************************** 4.8.主播取消已发的立即私密邀请  ****************************************/

class RequestZBCancelInstantInviteUserCallback : public IRequestZBCancelInstantInviteUserCallback {
	void OnZBCancelInstantInviteUser(ZBHttpCancelInstantInviteUserTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCancelInstantInvite( success : %s, task : %p,  isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRCancelInstantInvite( callback : %p, signature : %s )",
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

RequestZBCancelInstantInviteUserCallback gRequestZBCancelInstantInviteUserCallback;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    CancelInstantInvite
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_CancelInstantInvite
		(JNIEnv *env, jclass cls, jstring inviteId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::RejectInstanceInvite( inviteId : %s )",
			JString2String(env, inviteId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.ZBCancelInstantInviteUser(&gHttpRequestManager,
														   JString2String(env, inviteId),
														   &gRequestZBCancelInstantInviteUserCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;

}

/*********************************** 4.8.主播取消已发的立即私密邀请  ****************************************/
class RequestZBSetRoomCountDownCallback : public IRequestZBSetRoomCountDownCallback {
	void OnZBSetRoomCountDown(ZBHttpSetRoomCountDownTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBSetRoomCountDown( success : %s, task : %p,  isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnZBSetRoomCountDown( callback : %p, signature : %s )",
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

RequestZBSetRoomCountDownCallback gRequestZBSetRoomCountDownCallback;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequstJniSchedule
 * Method:    SetRoomCountDown
 * Signature: (Ljava/lang/String;ZILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequstJniSchedule_SetRoomCountDown
		(JNIEnv *env, jclass cls, jstring roomId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::RejectInstanceInvite( roomId : %s )",
			JString2String(env, roomId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.ZBSetRoomCountDown(&gHttpRequestManager,
															  JString2String(env, roomId),
															  &gRequestZBSetRoomCountDownCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;

}


