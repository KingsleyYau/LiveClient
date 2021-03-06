/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniPackage.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniPackage.h"

/*********************************** 5.1.获取背包礼物列表  ****************************************/

class RequestGiftListCallback : public IRequestGiftListCallback{
	void OnGiftList(HttpGiftListTask* task, bool success, int errnum, const string& errmsg, const BackGiftItemList& listItem, int totalCount){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetPackageGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getPackgetGiftArray(env, listItem);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PACKAGE_GIFT_ITEM_CLASS;
			signature += ";";
			signature += "I";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetPackageGiftList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetPackageGiftList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray, totalCount);
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

RequestGiftListCallback gRequestGiftListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniPackage
 * Method:    GetPackageGiftList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetPackageGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPackage_GetPackageGiftList
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPackageGiftList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GiftList(&gHttpRequestManager,
                                        &gRequestGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 5.2.获取试用券列表  ****************************************/

class RequestVoucherListCallback : public IRequestVoucherListCallback{
	void OnVoucherList(HttpVoucherListTask* task, bool success, int errnum, const string& errmsg, const VoucherList& list, int totalCount){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnVoucherList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getPackgetVoucherArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PACKAGE_VOUCHER_ITEM_CLASS;
			signature += ";";
			signature += "I";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetVouchersList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnVoucherList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray, totalCount);
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

RequestVoucherListCallback gRequestVoucherListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniPackage
 * Method:    GetVouchersList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetVouchersListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPackage_GetVouchersList
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetVouchersList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.VoucherList(&gHttpRequestManager,
                                        &gRequestVoucherListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 5.3.获取座驾列表  ****************************************/

class RequestRideListCallback : public IRequestRideListCallback{
	void OnRideList(HttpRideListTask* task, bool success, int errnum, const string& errmsg, const RideList& list, int totalCount){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRideList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getPackgetRideArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PACKAGE_RIDE_ITEM_CLASS;
			signature += ";";
			signature += "I";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetRidesList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRideList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jItemArray, totalCount);
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

RequestRideListCallback gRequestRideListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniPackage
 * Method:    GetRidesList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetRidesListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPackage_GetRidesList
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetRidesList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.RideList(&gHttpRequestManager,
                                        &gRequestRideListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 5.4.使用/取消座驾  ****************************************/

class RequestSetRideCallback : public IRequestSetRideCallback{
	void OnSetRide(HttpSetRideTask* task, bool success, int errnum, const string& errmsg){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetRide( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnSetRide( callback : %p, signature : %s )",
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

RequestSetRideCallback gRequestSetRideCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniPackage
 * Method:    UseOrCancelRide
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPackage_UseOrCancelRide
  (JNIEnv *env, jclass cls, jstring rideId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UseOrCancelRide( rideId : %s )",
			JString2String(env, rideId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.SetRide(&gHttpRequestManager,
    									JString2String(env, rideId),
                                        &gRequestSetRideCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 5.5.获取背包未读数量  ****************************************/

class RequestGetBackpackUnreadNumCallback : public IRequestGetBackpackUnreadNumCallback{
	void OnGetBackpackUnreadNum(HttpGetBackpackUnreadNumTask* task, bool success, int errnum, const string& errmsg,
			const HttpGetBackPackUnreadNumItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetBackpackUnreadNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;IIII)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetPackageUnreadCount", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetBackpackUnreadNum( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, item.total, item.voucherUnreadNum,
						item.giftUnreadNum, item.rideUnreadNum);
				env->DeleteLocalRef(jerrmsg);
			}
		}
		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetBackpackUnreadNumCallback gRequestGetBackpackUnreadNumCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniPackage
 * Method:    GetPackageUnreadCount
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetPackageUnreadCountCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniPackage_GetPackageUnreadCount
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetPackageUnreadCount()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetBackpackUnreadNum(&gHttpRequestManager,
                                        &gRequestGetBackpackUnreadNumCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
