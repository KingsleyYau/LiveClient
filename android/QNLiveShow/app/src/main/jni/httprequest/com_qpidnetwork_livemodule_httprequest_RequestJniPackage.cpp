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
	void OnGiftList(HttpGiftListTask* task, bool success, int errnum, const string& errmsg, const BackGiftItemList& listItem){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::onGetPackageGiftList( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		jobjectArray jItemArray = getPackgetGiftArray(env, listItem);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "[L";
			signature += PACKAGE_GIFT_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetPackageGiftList", signature.c_str());
			FileLog("httprequest", "JNI::onGetPackageGiftList( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItemArray);
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

    jlong taskId = -1;
    taskId = gHttpRequestController.GiftList(&gHttpRequestManager,
                                        &gRequestGiftListCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
