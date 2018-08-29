/*
 * com_qpidnetwork_anchor_httprequest_RequestJniOther.cpp
 *
 *  Created on: 2017-6-13
 *      Author: Hunter Mun
 */
#include "RequestJniConvert.h"
#include "com_qpidnetwork_anchor_httprequest_RequestJniOther.h"

#include <common/KZip.h>


/*********************************** 5.1. 同步配置    ****************************************/

class RequestZBGetConfigCallback : public IRequestZBGetConfigCallback {
	void OnZBGetConfig(ZBHttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const ZBHttpConfigItem& configItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        jobject jItem = getSynConfigItem(env, configItem);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);

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
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::onSynConfig( callback : %p, signature : %s )",
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

RequestZBGetConfigCallback gRequestZBGetConfigCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniOther
 * Method:    SynConfig
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnSynConfigCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniOther_SynConfig
  (JNIEnv *env, jclass cls, jobject callback){

    jlong taskId = -1;
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SynConfig()start %p", &gConfigRequestManager);
    taskId = gHttpRequestController.ZBGetConfig(&gConfigRequestManager,
                                        &gRequestZBGetConfigCallback);
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SynConfig()end %p", &gConfigRequestManager);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 5.2. 获取收入信息    ****************************************/

class RequestZBGetTodayCreditCallback : public IRequestZBGetTodayCreditCallback {
	void OnZBGetTodayCredit(ZBHttpGetTodayCreditTask* task, bool success, int errnum, const string& errmsg, const ZBHttpTodayCreditItem& configItem) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetTodayCredit( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;IIII)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onGetTodayCredit", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnGetTodayCredit( callback : %p, signature : %s )",
						callbackMethod, signature.c_str());
			if(callbackMethod != NULL){
				jstring jerrmsg = env->NewStringUTF(errmsg.c_str());
				env->CallVoidMethod(callBackObject, callbackMethod, success, errType, jerrmsg, configItem.monthCredit, configItem.monthCompleted, configItem.monthTarget, configItem.monthProgress);
				env->DeleteLocalRef(jerrmsg);
			}
		}

		if(callBackObject != NULL){
			env->DeleteGlobalRef(callBackObject);
		}

		ReleaseEnv(isAttachThread);
	}
};

RequestZBGetTodayCreditCallback gRequestZBGetTodayCreditCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniOther
 * Method:    GetTodayCredit
 * Signature: (Lcom/qpidnetwork/livemodule/httprequest/OnGetTodayCreditCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniOther_GetTodayCredit
  (JNIEnv *env, jclass cls, jobject callback){
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::GetTodayCredit()");

//    char* a = NULL;
//    char b = *a;
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBGetTodayCredit(&gHttpRequestManager,
    									&gRequestZBGetTodayCreditCallback);

    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}


/*********************************** 5.3.提交流媒体服务器测速结果  ****************************************/
class RequestZBServerSpeedCallback : public IRequestZBServerSpeedCallback {
	void OnZBServerSpeed(ZBHttpServerSpeedTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
        bool isAttachThread = false;
        GetEnv(&env, &isAttachThread);

        FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

        int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
        jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onRequest", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( callback : %p, signature : %s )",
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
RequestZBServerSpeedCallback gRequestZBServerSpeedCallback;
/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniOther
 * Method:    ServerSpeed
 * Signature: (Ljava/lang/String;ILcom/qpidnetwork/livemodule/httprequest/OnRequestCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniOther_ServerSpeed
  (JNIEnv *env, jclass cls, jstring sid, jint res, jobject callback) {
    FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnServerSpeed( sid : %s, res : %d )",
			JString2String(env, sid).c_str(), res);
    jlong taskId = -1;
    taskId = gHttpRequestController.ZBServerSpeed(&gHttpRequestManager,
    													JString2String(env, sid),
    													res,
    													&gRequestZBServerSpeedCallback);
    jobject obj = env->NewGlobalRef(callback);
    putCallbackIntoMap(taskId, obj);

    return taskId;
}

/*********************************** 5.4.提交crash dump文件） ****************************************/
class RequestZBCrashFileCallback : public IRequestZBCrashFileCallback {
	void OnZBCrashFile(ZBHttpCrashFileTask* task, bool success, int errnum, const string& errmsg) {
		JNIEnv* env = NULL;
		bool isAttachThread = false;
		GetEnv(&env, &isAttachThread);

		FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUploadCrashFile( success : %s, task : %p, isAttachThread:%d )", success?"true":"false", task, isAttachThread);

		int errType = HTTPErrorTypeToInt((ZBHTTP_LCC_ERR_TYPE)errnum);
		/*callback object*/
		jobject callBackObject = getCallbackObjectByTask((long)task);
		if(callBackObject != NULL){
			jclass callBackCls = env->GetObjectClass(callBackObject);
			string signature = "(ZILjava/lang/String;)V";
			jmethodID callbackMethod = env->GetMethodID(callBackCls, "onUploadCrashFile", signature.c_str());
			FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::OnUploadCrashFile( callback : %p, signature : %s )",
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

RequestZBCrashFileCallback gRequestZBCrashFileCallback;

/*
 * Class:     com_qpidnetwork_anchor_httprequest_RequestJniOther
 * Method:    UploadCrashFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/qpidnetwork/livemodule/httprequest/OnRequestLSUploadCrashFileCallback;)J
 */
JNIEXPORT jlong JNICALL Java_com_qpidnetwork_anchor_httprequest_RequestJniOther_UploadCrashFile
		(JNIEnv *env, jclass cls, jstring deviceId, jstring directory, jstring tmpDirectory, jobject callback) {
	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::UploadCrashFile( deviceId : %s, directory : %s, tmpDirectory : %s)",
			JString2String(env, deviceId).c_str(),
	        JString2String(env, directory).c_str(),
            JString2String(env, tmpDirectory).c_str());
	jlong taskId = -1;

    const char *cpDeviceId = env->GetStringUTFChars(deviceId, 0);
    const char *cpDirectory = env->GetStringUTFChars(directory, 0);
    const char *cpTmpDirectory = env->GetStringUTFChars(tmpDirectory, 0);

    FileLog("httprequest", "UploadCrashFile ( directory : %s, tmpDirectory : %s ) ", cpDirectory, cpTmpDirectory);

    time_t stm = time(NULL);
    struct tm tTime;
    localtime_r(&stm, &tTime);
    char pZipFileName[1024] = {'\0'};
    snprintf(pZipFileName, sizeof(pZipFileName), "%s/crash-%d-%02d-%02d_[%02d-%02d-%02d].zip", \
    		cpTmpDirectory, tTime.tm_year + 1900, tTime.tm_mon + 1, \
    		tTime.tm_mday, tTime.tm_hour, tTime.tm_min, tTime.tm_sec);

    // create zip
    KZip zip;
    string comment = "";
    const char password[] = {
            0x51, 0x70, 0x69, 0x64, 0x5F, 0x44, 0x61, 0x74, 0x69, 0x6E, 0x67, 0x00
    }; // Qpid_Dating

    bool bFlag = zip.CreateZipFromDir(cpDirectory, pZipFileName, "", comment);

    FileLog("httprequest", "UploadCrashLog ( pZipFileName : %s  zip  : %s ) ", pZipFileName, bFlag?"ok":"fail");

    if (bFlag) {
        taskId = gHttpRequestController.ZBCrashFile(&gHttpRequestManager,
                                                  JString2String(env, deviceId),
                                                  pZipFileName,
                                                  &gRequestZBCrashFileCallback);
        jobject obj = env->NewGlobalRef(callback);
        putCallbackIntoMap(taskId, obj);
    }

    env->ReleaseStringUTFChars(deviceId, cpDeviceId);
    env->ReleaseStringUTFChars(directory, cpDirectory);
    env->ReleaseStringUTFChars(tmpDirectory, cpTmpDirectory);

	return taskId;
}