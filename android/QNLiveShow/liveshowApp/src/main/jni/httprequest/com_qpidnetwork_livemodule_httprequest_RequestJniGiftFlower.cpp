/*
 * com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower.h"

/*********************************** 15.1.获取鲜花礼品列表  ****************************************/

class RequestGetStoreGiftListCallback : public IRequestGetStoreGiftListCallback{
	void OnGetStoreGiftList(HttpGetStoreGiftListTask* task, bool success, int errnum, const string& errmsg, const StoreFlowerGiftList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetStoreGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getStoreFlowerGiftListArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += FLOWERGIFT_STROREFLOWERGIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetStoreGiftList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onGetStoreGiftList( callback : %p, signature : %s )",
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

RequestGetStoreGiftListCallback gRequestGetStoreGiftListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetStoreGiftList
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetPackageGiftListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetStoreGiftList
  (JNIEnv *env, jclass cls, jstring anchorId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetStoreGiftList(anchorId : %s)", JString2String(env, anchorId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetStoreGiftList(&gHttpRequestManager,
                                                     JString2String(env, anchorId),
                                                     &gRequestGetStoreGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 15.2.获取鲜花礼品详情  ****************************************/

class RequestGetFlowerGiftDetailCallback : public IRequestGetFlowerGiftDetailCallback{
	void OnGetFlowerGiftDetail(HttpGetFlowerGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpFlowerGiftItem& item) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetFlowerGiftDetail( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobject jItem = getFlowerGiftItem(env, item);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += FLOWERGIFT_FLOWERGIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetFlowerGiftDetail", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetFlowerGiftDetail( callback : %p, signature : %s )",
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

RequestGetFlowerGiftDetailCallback gRequestGetFlowerGiftDetailCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetFlowerGiftDetail
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVouchersListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetFlowerGiftDetail
  (JNIEnv *env, jclass cls, jstring giftId, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetFlowerGiftDetail(giftId : %s)", JString2String(env, giftId).c_str());
    jlong taskId = -1;
    taskId = gHttpRequestController.GetFlowerGiftDetail(&gHttpRequestManager,
                                        JString2String(env, giftId),
                                        &gRequestGetFlowerGiftDetailCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 15.3.获取座驾列表  ****************************************/

class RequestGetRecommendGiftListCallback : public IRequestGetRecommendGiftListCallback {
	void OnGetRecommendGiftList(HttpGetRecommendGiftListTask* task, bool success, int errnum, const string& errmsg, const FlowerGiftList& list) {

	}
};

RequestGetRecommendGiftListCallback gRequestGetRecommendGiftListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetRecommendGiftList
 * Signature: (Ljava/lang/String;Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnGetRidesListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetRecommendGiftList
  (JNIEnv *env, jclass cls, jstring giftId, jstring anchorId, jint number, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetRecommendGiftList(giftId : %s, anchorId : %s, number : %d)", JString2String(env, giftId).c_str(), JString2String(env, anchorId).c_str(), number);
    jlong taskId = -1;
    taskId = gHttpRequestController.GetRecommendGiftList(&gHttpRequestManager,
                                                        JString2String(env, giftId),
                                                        JString2String(env, anchorId),
                                                        number,
                                                        &gRequestGetRecommendGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 15.4.使用/取消座驾  ****************************************/

class RequestGetResentRecipientListCallback : public IRequestGetResentRecipientListCallback {
	void OnGetResentRecipientList(HttpGetResentRecipientListTask* task, bool success, int errnum, const string& errmsg, const RecipientAnchorList& list) {

	}
};

RequestGetResentRecipientListCallback gRequestGetResentRecipientListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetResentRecipientList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetResentRecipientList
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetResentRecipientList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetResentRecipientList(&gHttpRequestManager,
                                                            &gRequestGetResentRecipientListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 15.5.获取My delivery列表  ****************************************/

class RequestGetDeliveryListCallback : public IRequestGetDeliveryListCallback {
	void OnGetDeliveryList(HttpGetDeliveryListTask* task, bool success, int errnum, const string& errmsg, const DeliveryList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetDeliveryList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getDeliveryListArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += FLOWERGIFT_DELIVERY_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetDeliveryList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetDeliveryList( callback : %p, signature : %s )",
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

RequestGetDeliveryListCallback gRequestGetDeliveryListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetDeliveryList
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetPackageUnreadCountCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetDeliveryList
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetDeliveryList()");
    jlong taskId = -1;
    taskId = gHttpRequestController.GetDeliveryList(&gHttpRequestManager,
                                        &gRequestGetDeliveryListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 15.6.获取购物车礼品种类数  ****************************************/

class RequestGetCartGiftTypeNumCallback : public IRequestGetCartGiftTypeNumCallback{
	void OnGetCartGiftTypeNum(HttpGetCartGiftTypeNumTask* task, bool success, int errnum, const string& errmsg, int num) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCartGiftTypeNum( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "I";       // num
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCartGiftTypeNum", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCartGiftTypeNum( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, num);
				env->DeleteLocalRef(jerrmsg);
			}
		}


		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestGetCartGiftTypeNumCallback gRequestGetCartGiftTypeNumCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetCartGiftTypeNum
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetCartGiftTypeNum
		(JNIEnv *env, jclass cls, jstring anchorId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCartGiftTypeNum(anchorId : %s)", JString2String(env, anchorId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.GetCartGiftTypeNum(&gHttpRequestManager,
	                                                    JString2String(env, anchorId),
														 &gRequestGetCartGiftTypeNumCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 15.7.获取购物车My cart列表  ****************************************/

class RequestGetCartGiftListCallback : public IRequestGetCartGiftListCallback {
	void OnGetCartGiftList(HttpGetCartGiftListTask* task, bool success, int errnum, const string& errmsg, int total, const MyCartItemList& list) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCartGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getMyCartListArray(env, list);
		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		//int errType = HTTPErrorTypeToInt(GetStringToHttpErrorType(errnum));

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "I";
			signature += "[L";
			signature += FLOWERGIFT_MYCART_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetCartGiftList", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetCartGiftList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, total, jItemArray);
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

RequestGetCartGiftListCallback gRequestGetCartGiftListCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    GetCartGiftList
 * Signature: (IILcom/qpidnetwork/livemodule/httprequest/OnGetVouchersListCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_GetCartGiftList
  (JNIEnv *env, jclass cls, jint start, jint step, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCartGiftList(start : %d, step : %d)", start, step);
	jlong taskId = -1;
	taskId = gHttpRequestController.GetCartGiftList(&gHttpRequestManager,
	                                                    start,
	                                                    step,
														&gRequestGetCartGiftListCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
  }

/*********************************** 15.8.添加购物车商品  ****************************************/

class RequestAddCartGiftCallback : public IRequestAddCartGiftCallback {
	void OnAddCartGift(HttpAddCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddCartGift( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnAddCartGift( callback : %p, signature : %s )",
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

RequestAddCartGiftCallback gRequestAddCartGiftCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    AddCartGift
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_AddCartGift
		(JNIEnv *env, jclass cls, jstring anchorId, jstring giftId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCartGiftTypeNum(anchorId : %s, giftId : %s)", JString2String(env, anchorId).c_str(), JString2String(env, giftId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.AddCartGift(&gHttpRequestManager,
	                                            JString2String(env, anchorId),
	                                            JString2String(env, giftId),
												&gRequestAddCartGiftCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 15.9.修改购物车商品数量  ****************************************/

class RequestChangeCartGiftNumberCallback : public IRequestChangeCartGiftNumberCallback {
	void OnChangeCartGiftNumber(HttpChangeCartGiftNumberTask* task, bool success, int errnum, const string& errmsg, int status) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnChangeCartGiftNumber( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnChangeCartGiftNumber( callback : %p, signature : %s )",
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

RequestChangeCartGiftNumberCallback gRequestChangeCartGiftNumberCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    ChangeCartGiftNumber
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_ChangeCartGiftNumber
		(JNIEnv *env, jclass cls, jstring anchorId, jstring giftId, jint giftNumber, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetCartGiftTypeNum(anchorId : %s, giftId : %s, giftNumber : %d)", JString2String(env, anchorId).c_str(), JString2String(env, giftId).c_str(), giftNumber);
	jlong taskId = -1;
	taskId = gHttpRequestController.ChangeCartGiftNumber(&gHttpRequestManager,
	                                            JString2String(env, anchorId),
	                                            JString2String(env, giftId),
	                                            giftNumber,
												&gRequestChangeCartGiftNumberCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 15.10.删除购物车商品  ****************************************/

class RequestRemoveCartGiftCallback : public IRequestRemoveCartGiftCallback {
	void OnRemoveCartGift(HttpRemoveCartGiftTask* task, bool success, int errnum, const string& errmsg, int status) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRemoveCartGift( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnRemoveCartGift( callback : %p, signature : %s )",
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

RequestRemoveCartGiftCallback gRequestRemoveCartGiftCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    RemoveCartGift
 * Signature: (Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_RemoveCartGift
		(JNIEnv *env, jclass cls, jstring anchorId, jstring giftId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::RemoveCartGift(anchorId : %s, giftId : %s)", JString2String(env, anchorId).c_str(), JString2String(env, giftId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.RemoveCartGift(&gHttpRequestManager,
	                                            JString2String(env, anchorId),
	                                            JString2String(env, giftId),
												&gRequestRemoveCartGiftCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 15.11.Checkout商品  ****************************************/

class RequestCheckOutCartGiftCallback : public IRequestCheckOutCartGiftCallback {
	void OnCheckOutCartGift(HttpCheckOutCartGiftTask* task, bool success, int errnum, const string& errmsg, const HttpCheckoutItem& item) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCheckOutCartGift( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);
		jobject jItem = getCheckoutItem(env, item);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += FLOWERGIFT_CHECKOUT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onCheckOutCartGift", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCheckOutCartGift( callback : %p, signature : %s )",
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

RequestCheckOutCartGiftCallback gRequestCheckOutCartGiftCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    CheckOutCartGift
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_CheckOutCartGift
		(JNIEnv *env, jclass cls, jstring anchorId, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CheckOutCartGift(anchorId : %s)", JString2String(env, anchorId).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.CheckOutCartGift(&gHttpRequestManager,
	                                            JString2String(env, anchorId),
												&gRequestCheckOutCartGiftCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}

/*********************************** 15.12.生成订单  ****************************************/

class RequestCreateGiftOrderCallback : public IRequestCreateGiftOrderCallback {
	void OnCreateGiftOrder(HttpCreateGiftOrderTask* task, bool success, int errnum, const string& errmsg, const string& orderNumber) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCreateGiftOrder( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((HTTP_LCC_ERR_TYPE)errnum);

		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "Ljava/lang/String;";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onCreateGiftOrder", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnCreateGiftOrder( callback : %p, signature : %s )",
					callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jorderNumber = env->NewStringUTF(orderNumber.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, jorderNumber);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jorderNumber);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestCreateGiftOrderCallback gRequestCreateGiftOrderCallback;

/*
 * Class:     com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower
 * Method:    CreateGiftOrder
 * Signature: (Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnGetVoucherAvailableInfoCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_livemodule_httprequest_RequestJniGiftFlower_CreateGiftOrder
		(JNIEnv *env, jclass cls, jstring anchorId, jstring greetingMessage, jstring specialDeliveryRequest, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::CheckOutCartGift(anchorId : %s, greetingMessage : %s, specialDeliveryRequest : %s)", JString2String(env, anchorId).c_str(), JString2String(env, greetingMessage).c_str(), JString2String(env, specialDeliveryRequest).c_str());
	jlong taskId = -1;
	taskId = gHttpRequestController.CreateGiftOrder(&gHttpRequestManager,
	                                            JString2String(env, anchorId),
	                                            JString2String(env, greetingMessage),
	                                            JString2String(env, specialDeliveryRequest),
												&gRequestCreateGiftOrderCallback);

	jobject obj = env->NewGlobalRef(callback);
	putCallbackIntoMap(taskId, obj);

	return taskId;
}