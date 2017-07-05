/*
 * com_qpidnetwork_httprequest_RequestJni.cpp
 *
 *  Created on: 2017-5-17
 *      Author: Hunter Mun
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_httprequest_RequestJni.h"

#include <crashhandler/CrashHandler.h>
#include <common/IPAddress.h>
#include <common/md5.h>
#include <common/command.h>

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    SetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetLogDirectory
  (JNIEnv *env, jclass cls, jstring directory){

	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	KLog::SetLogDirectory(cpDirectory);
	HttpClient::SetLogDirectory(cpDirectory);
	CrashHandler::GetInstance()->SetLogDirectory(cpDirectory);

	GetPhoneInfo();

	FileLog("httprequest", "SetLogDirectory ( directory : %s ) ", cpDirectory);
	FileLog("httprequest", "SetLogDirectory ( Android CPU ABI : %s ) ", GetPhoneCpuAbi().c_str());

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    SetVersionCode
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetVersionCode
  (JNIEnv *env, jclass cls, jstring version){
	const char *cpVersion = env->GetStringUTFChars(version, 0);
	gHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	gPhotoUploadRequestManager.SetVersionCode(COMMON_VERSION_CODE, cpVersion);
	CrashHandler::GetInstance()->SetVersion(cpVersion);
	env->ReleaseStringUTFChars(version, cpVersion);
}

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    SetCookiesDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetCookiesDirectory
  (JNIEnv *env, jclass cls, jstring directory){
	const char *cpDirectory = env->GetStringUTFChars(directory, 0);

	HttpClient::SetCookiesDirectory(cpDirectory);

	FileLog("httprequest", "SetCookiesDirectory ( directory : %s ) ", cpDirectory);

	env->ReleaseStringUTFChars(directory, cpDirectory);
}

/*
 * Class:     com_qpidnetwork_request_RequestJni
 * Method:    SetWebSite
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetWebSite
  (JNIEnv *env, jclass cls, jstring webSite) {
	const char *cpWebSite = env->GetStringUTFChars(webSite, 0);

	gHttpRequestManager.SetWebSite(cpWebSite);

	env->ReleaseStringUTFChars(webSite, cpWebSite);
}

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    SetPhotoUploadSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetPhotoUploadSite
  (JNIEnv *env, jclass cls, jstring uploadSite) {
	const char *cpUploadSite = env->GetStringUTFChars(uploadSite, 0);

	gPhotoUploadRequestManager.SetWebSite(cpUploadSite);

	env->ReleaseStringUTFChars(uploadSite, cpUploadSite);
}


/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    StopRequest
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_StopRequest
  (JNIEnv *env, jclass cls, jlong requestId){
	gHttpRequestController.Stop(requestId);
}

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    GetLocalMacMD5
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_qpidnetwork_httprequest_RequestJni_GetLocalMacMD5
  (JNIEnv *env, jclass cls){
	string macAddress = "";

	list<IpAddressNetworkInfo> infoList = IPAddress::GetNetworkInfoList();
	if( infoList.size() > 0 && infoList.begin() != infoList.end() ) {
		IpAddressNetworkInfo info = *(infoList.begin());
		macAddress = info.mac;
	}

	char deviceId[128] = {'\0'};
	memset(deviceId, '\0', sizeof(deviceId));
	GetMD5String(macAddress.c_str(), deviceId);

	return env->NewStringUTF(deviceId);
}

/*
 * Class:     com_qpidnetwork_httprequest_RequestJni
 * Method:    SetDeviceId
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_httprequest_RequestJni_SetDeviceId
  (JNIEnv *env, jclass cls, jstring deviceId){
	const char *cpDeviceId = env->GetStringUTFChars(deviceId, 0);
	CrashHandler::GetInstance()->SetDeviceId(cpDeviceId);
	env->ReleaseStringUTFChars(deviceId, cpDeviceId);
}















