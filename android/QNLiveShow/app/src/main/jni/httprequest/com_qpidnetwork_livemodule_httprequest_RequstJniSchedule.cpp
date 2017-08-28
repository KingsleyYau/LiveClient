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

        FileLog("httprequest", "JNI::onGetScheduleInviteList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getBookInviteArray(env, item.list);

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
			FileLog("httprequest", "JNI::onGetScheduleInviteList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, item.total, jItemArray);
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

        FileLog("httprequest", "JNI::OnHandleBooking( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnHandleBooking( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
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
  (JNIEnv *env, jclass cls, jstring inviteId, jboolean isHandled, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.HandleBooking(&gHttpRequestManager,
    									JString2String(env, inviteId),
    									isHandled,
                                        &gRequestHandleBookingCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 4.3.取消预约邀请  ****************************************/

class RequestCancelPrivateRequestCallback : public IRequestCancelPrivateRequestCallback{
	void OnCancelPrivateRequest(HttpCancelPrivateRequestTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnCancelPrivateRequest( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog("httprequest", "JNI::OnCancelPrivateRequest( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestCancelPrivateRequestCallback gRequestCancelPrivateRequestCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequstJniSchedule
 * Method:    CancelScheduledInvite
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequstJniSchedule_CancelScheduledInvite
  (JNIEnv *env, jclass cls, jstring inviteId, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.CancelPrivateRequest(&gHttpRequestManager,
    									JString2String(env, inviteId),
                                        &gRequestCancelPrivateRequestCallback);

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

        FileLog("httprequest", "JNI::OnManBookingUnreadUnhandleNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;IIII)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCountOfUnreadAndPendingInvite", signature.c_str());
			FileLog("httprequest", "JNI::OnManBookingUnreadUnhandleNum( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, item.total, item.handleNum, item.scheduledUnreadNum, item.historyUnreadNum);
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

    jlong taskId = -1;
    taskId = gHttpRequestController.ManBookingUnreadUnhandleNum(&gHttpRequestManager,
    									&gRequestManBookingUnreadUnhandleNumCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
