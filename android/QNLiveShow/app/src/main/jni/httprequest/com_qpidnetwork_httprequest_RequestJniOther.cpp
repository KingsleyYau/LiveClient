/*
 * com_qpidnetwork_httprequest_RequestJniOther.cpp
 *
 *  Created on: 2017-6-13
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_httprequest_RequestJniOther.h"
#include "RequestJniConvert.h"


/*********************************** 5.1. 同步配置    ****************************************/

class RequestGetLiveRoomConfigCallback : public IRequestGetLiveRoomConfigCallback{
	void OnGetLiveRoomConfig(HttpGetLiveRoomConfigTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomConfigItem& item){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnGetLiveRoomConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = NULL;
		JavaItemMap::iterator itr = gJavaItemMap.find(OTHER_CONFIG_ITEM_CLASS);
		if( itr != gJavaItemMap.end() ) {
			FileLog("httprequest", "JNI::OnGetLiveRoomConfig( itr != gJavaItemMap.end() )");
			jclass cls = env->GetObjectClass(itr->second);
			jmethodID init = env->GetMethodID(cls, "<init>", "(Ljava/lang/String;ILjava/lang/String;ILjava/lang/String;I)V");

			jstring jimSvr_ip = env->NewStringUTF(item.imSvr_ip.c_str());
			jstring jhttpSvr_ip = env->NewStringUTF(item.httpSvr_ip.c_str());
			jstring juploadSvr_ip = env->NewStringUTF(item.uploadSvr_ip.c_str());

			jItem = env->NewObject(cls, init,
					jimSvr_ip,
					item.imSvr_port,
					jhttpSvr_ip,
					item.httpSvr_port,
					juploadSvr_ip,
					item.uploadSvr_port
					);

			env->DeleteLocalRef(jimSvr_ip);
			env->DeleteLocalRef(jhttpSvr_ip);
			env->DeleteLocalRef(juploadSvr_ip);
		}


		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;";
			signature += "L";
			signature += OTHER_CONFIG_ITEM_CLASS;
			signature += ";";
			signature += ")V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onSynConfig", signature.c_str());
			FileLog("httprequest", "JNI::OnGetLiveRoomConfig( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jItem);
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

RequestGetLiveRoomConfigCallback gRequestGetLiveRoomConfigCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniOther
 * Method:    SynConfig
 * Signature: (Lcom/qpidnetwork/httprequest/OnSynConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniOther_SynConfig
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.GetLiveRoomConfig(&gHttpRequestManager,
                                        &gRequestGetLiveRoomConfigCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 5.2. 上传图片    ****************************************/

class RequestUploadLiveRoomImgCallback : public IRequestUploadLiveRoomImgCallback{
	void OnUploadLiveRoomImg(HttpUploadLiveRoomImgTask* task, bool success, int errnum, const string& errmsg, const string& imageId, const string& imageUrl){
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog("httprequest", "JNI::OnUploadLiveRoomImg( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onUploadPicture", signature.c_str());
			FileLog("httprequest", "JNI::OnUploadLiveRoomImg( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				jstring jimageId = env->NewStringUTF(imageId.c_str());
				jstring jimageUrl = env->NewStringUTF(imageUrl.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errnum, jerrmsg, jimageId, jimageUrl);
				env->DeleteLocalRef(jerrmsg);
				env->DeleteLocalRef(jimageId);
				env->DeleteLocalRef(jimageUrl);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestUploadLiveRoomImgCallback gRequestUploadLiveRoomImgCallback;

/*
 * Class:     com_qpidnetwork_httprequest_RequestJniOther
 * Method:    UploadPicture
 * Signature: (ILjava/lang/String;Lcom/qpidnetwork/httprequest/OnUploadPictureCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_httprequest_RequestJniOther_UploadPicture
  (JNIEnv *env, jclass cls, jint uploadPhotoType, jstring filePath, jobject callback){

    jlong taskId = -1;
    taskId = gHttpRequestController.UploadLiveRoomImg(&gPhotoUploadRequestManager,
    												gToken,
    												IntToUploadPhotoType(uploadPhotoType),
    												JString2String(env, filePath),
    												&gRequestUploadLiveRoomImgCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}
