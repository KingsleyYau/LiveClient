/*
 * com_qpidnetwork_http_request_RequestJni.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */
#include "GlobalFunc.h"
#include "com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni.h"

#include <crashhandler/CrashHandler.h>

#include <common/IPAddress.h>
#include <common/md5.h>
#include <common/command.h>
#include <common/KZip.h>

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetLogDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetLogDirectory
  (JNIEnv *env, jclass, jstring directory) {
	string cpDirectory = JString2String(env, directory);

	KLog::SetLogDirectory(cpDirectory);
	HttpClient::SetLogDirectory(cpDirectory);
	CrashHandler::GetInstance()->SetLogDirectory(cpDirectory);

	GetPhoneInfo();

	FileLog("httprequest", "SetLogDirectory ( directory : %s ) ", cpDirectory.c_str());
	FileLog("httprequest", "SetLogDirectory ( Android CPU ABI : %s ) ", GetPhoneCpuAbi().c_str());

}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetVersionCode
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetVersionCode
  (JNIEnv *env, jclass cls, jstring version) {
	string cpVersion = JString2String(env, version);
	gLSLiveChatHttpRequestManager.SetVersionCode(cpVersion);
	CrashHandler::GetInstance()->SetVersion(cpVersion);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetCookiesDirectory
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetCookiesDirectory
  (JNIEnv *env, jclass, jstring directory) {
	string cpDirectory = JString2String(env, directory);

	HttpClient::SetCookiesDirectory(cpDirectory);

	FileLog("httprequest", "SetCookiesDirectory ( directory : %s ) ", cpDirectory.c_str());

}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetWebSite
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetWebSite
  (JNIEnv *env, jclass cls, jstring webSite, jstring appSite) {
	string cpWebSite = JString2String(env, webSite);
	string cpAppSite = JString2String(env, appSite);

	gLSLiveChatHttpRequestHostManager.SetWebSite(cpWebSite);
	gLSLiveChatHttpRequestHostManager.SetAppSite(cpAppSite);


    //HttpClient::CleanCookies();
    //list<string> cookies;
    //HttpClient::GetCookiesInfo();
    //cookies.push_back("demo-mobile.charmdate.com\tFALSE\t/\tFALSE\t0\tPHPSESSID\tdkq2algb36pabivu6s1lero8p3");
    //cookies.push_back("demo-mobile.charmdate.com\tFALSE\t/\tFALSE\t1\tCHNCOOKAUTOTOKEN\tdeleted");
    //HttpClient::SetCookiesInfo(cookies);
    //HttpClient::GetCookiesInfo();


}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetPublicWebSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetPublicWebSite
  (JNIEnv *env, jclass cls, jstring chatVoiceSite)
{
	string cpChatVoiceSite = JString2String(env, chatVoiceSite);
	gLSLiveChatHttpRequestHostManager.SetChatVoiceSite(cpChatVoiceSite);

}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetChangeSite
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetChangeSite
		(JNIEnv *env, jclass cls, jstring changeSite) {
	string cpChangeSite = JString2String(env, changeSite);
	gLSLiveChatHttpRequestHostManager.SetChangeSite(cpChangeSite);

}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetAuthorization
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetAuthorization
  (JNIEnv *env, jclass, jstring user, jstring password) {
	string cpUser = JString2String(env, user);
	string cpPassword = JString2String(env, password);
	gLSLiveChatHttpRequestManager.SetAuthorization(cpUser, cpPassword);

}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    CleanCookies
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_CleanCookies
  (JNIEnv *, jclass) {
	HttpClient::CleanCookies();
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetCookies
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetCookies
  (JNIEnv *env, jclass, jstring site) {
	string cpSite = JString2String(env, site);
	string cookies = HttpClient::GetCookies(cpSite);
	return env->NewStringUTF(cookies.c_str());
}


/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetCookiesInfo
 * Signature: ()[Ljava/lang/String;
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetCookiesInfo
  (JNIEnv *env, jclass cls)
{
	jobjectArray jStringArray = NULL;

	list<string> cookies = HttpClient::GetCookiesInfo();

	jclass jStringCls = env->FindClass("java/lang/String");
	jStringArray = env->NewObjectArray(cookies.size(), jStringCls, NULL);

	FileLog("httprequest", "GetCookiesInfo() JNI cookies.size:%d, jStringArray:%p", cookies.size(), jStringArray);

	if (NULL != jStringArray)
	{
		int i = 0;
		for (list<string>::const_iterator iter = cookies.begin();
			 iter != cookies.end();
			 iter++, i++)
		{
			jstring item = env->NewStringUTF((*iter).c_str());

			FileLog("httprequest", "GetCookiesInfo() JNI i:%d, cookie:%s, item:%p", i, (*iter).c_str(), item);
			env->SetObjectArrayElement(jStringArray, i, item);

			env->DeleteLocalRef(item);
		}
	}

	return jStringArray;
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetCookiesItem
 * Signature: ()["com/qpidnetwork/request/item/CookiesItem";
 */
JNIEXPORT jobjectArray JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetCookiesItem
  (JNIEnv *env, jclass cls)
{
	FileLog("httprequest","GetCookiesItem() begin");
	jobjectArray jCookiesArray = NULL;
	list<CookiesItem> cookies = HttpClient::GetCookiesItem();
	jclass jItemCls = env->FindClass("com/qpidnetwork/request/item/CookiesItem");
	if(!jItemCls)
	{
		FileLog("httprequest", "GetCookiesItem() JNI jclass is NULL");
		return NULL;
	}

	jmethodID jItemMethod = env->GetMethodID(jItemCls, "<init>", "()V");
	if(!jItemMethod)
	{
		FileLog("httprequest","GetCookiesItem() <init>ID is NULL end");
		env->DeleteLocalRef(jItemCls);
		return NULL;
	}

	jmethodID jItemInitMethod = env->GetMethodID(jItemCls,"init","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	if(!jItemInitMethod)
	{
		FileLog("httprequest","GetCookiesItem() init()ID is NULL end");
		env->DeleteLocalRef(jItemCls);
		return NULL;
	}

	jCookiesArray = env->NewObjectArray(cookies.size(), jItemCls, NULL);
	FileLog("httprequest", "GetCookiesItem() JNI cookies.size:%d, jCookiesArray:%p", cookies.size(), jCookiesArray);

	if (NULL != jCookiesArray)
	{
		int i = 0;
		for (list<CookiesItem>::const_iterator iter = cookies.begin();
			 iter != cookies.end();
			 iter++, i++)
		{
			jstring domain = env->NewStringUTF((*iter).m_domain.c_str());
			jstring accessOtherWeb = env->NewStringUTF((*iter).m_accessOtherWeb.c_str());
			jstring symbol = env->NewStringUTF((*iter).m_symbol.c_str());
			jstring isSend = env->NewStringUTF((*iter).m_isSend.c_str());
			jstring expiresTime = env->NewStringUTF((*iter).m_expiresTime.c_str());
			jstring cName = env->NewStringUTF((*iter).m_cName.c_str());
			jstring value = env->NewStringUTF((*iter).m_value.c_str());
			jobject objCookiesItem       = env->NewObject(jItemCls, jItemMethod);
			if(!objCookiesItem)
			{
				FileLog("httprequest","GetCookiesItem() objCookiesItem is NULL end");
				env->DeleteLocalRef(jItemCls);
				env->DeleteLocalRef(jCookiesArray);
				return NULL;
			}
			env->CallVoidMethod(objCookiesItem, jItemInitMethod, domain, accessOtherWeb, symbol, isSend, expiresTime, cName, value);
			env->DeleteLocalRef(domain);
			env->DeleteLocalRef(accessOtherWeb);
			env->DeleteLocalRef(symbol);
			env->DeleteLocalRef(isSend);
			env->DeleteLocalRef(expiresTime);
			env->DeleteLocalRef(cName);
			env->DeleteLocalRef(value);
			env->SetObjectArrayElement(jCookiesArray, i, objCookiesItem);
		}
		env->DeleteLocalRef(jItemCls);
	}
	FileLog("httprequest", "GetCookiesItem() JNI end");
	return jCookiesArray;
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    StopRequest
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_StopRequest
  (JNIEnv *env, jclass, jlong requestId) {
	gLSLiveChatHttpRequestManager.StopRequest(requestId);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    StopAllRequest
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_StopAllRequest
  (JNIEnv *env, jclass) {
	gLSLiveChatHttpRequestManager.StopAllRequest();
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetDeviceId
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetDeviceId
  (JNIEnv *env, jclass) {
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
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    SetDeviceId
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetDeviceId
  (JNIEnv *env, jclass, jstring deviceId) {
	string cpDeviceId = JString2String(env, deviceId);
	CrashHandler::GetInstance()->SetDeviceId(cpDeviceId);
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetDownloadContentLength
 * Signature: (J)IV
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetDownloadContentLength
  (JNIEnv *env, jclass cls, jlong requestId)
{
	jint jiContentLength = 0;
	const HttpRequest* request = gLSLiveChatHttpRequestManager.GetRequestById(requestId);
	if (NULL != request) {
		int iContentLength = 0;
		int iRecvLength = 0;
		request->GetRecvDataCount(iContentLength, iRecvLength);
		jiContentLength = iContentLength;
	}
	return jiContentLength;
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetRecvLength
 * Signature: (J)IV
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetRecvLength
  (JNIEnv *env, jclass cls, jlong requestId)
{
	jint jiRecvLength = 0;
	const HttpRequest* request = gLSLiveChatHttpRequestManager.GetRequestById(requestId);
	if (NULL != request) {
		int iContentLength = 0;
		int iRecvLength = 0;
		request->GetRecvDataCount(iContentLength, iRecvLength);
		jiRecvLength = iRecvLength;
	}
	return jiRecvLength;
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetUploadContentLength
 * Signature: (J)IV
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetUploadContentLength
  (JNIEnv *env, jclass cls, jlong requestId)
{
	jint jiContentLength = 0;
	const HttpRequest* request = gLSLiveChatHttpRequestManager.GetRequestById(requestId);
	if (NULL != request) {
		int iContentLength = 0;
		int iSendLength = 0;
		request->GetSendDataCount(iContentLength, iSendLength);
		jiContentLength = iContentLength;
	}
	return jiContentLength;
}

/*
 * Class:     com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni
 * Method:    GetSendLength
 * Signature: (J)IV
 */
JNIEXPORT jint JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_GetSendLength
  (JNIEnv *env, jclass cls, jlong requestId)
{
	jint jiSendLength = 0;
	const HttpRequest* request = gLSLiveChatHttpRequestManager.GetRequestById(requestId);
	if (NULL != request) {
		int iContentLength = 0;
		int iSendLength = 0;
		request->GetSendDataCount(iContentLength, iSendLength);
		jiSendLength = iSendLength;
	}
	return jiSendLength;
}

  JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetCookiesInfo
    (JNIEnv *env, jclass cls, jobjectArray cookies) {
    FileLog("httprequest", "LiveChat.Native::SetCookiesInfo() start");

    	// 获取IP列表
    	list<string> cookiesList;
    	if (NULL != cookies) {
    		for (int i = 0; i < env->GetArrayLength(cookies); i++) {
    			jstring cookie = (jstring)env->GetObjectArrayElement(cookies, i);
    			string cookieStr = JString2String(env, cookie);
    			if (!cookieStr.empty()) {
    			FileLog("httprequest", "LiveChat.Native::SetCookiesInfo(strCookie:%s) start", cookieStr.c_str());
    				cookiesList.push_back(cookieStr);
    			}
    		}
    	}
    	if (cookiesList.size() > 0) {
    	    HttpClient::SetCookiesInfo(cookiesList);
    	}
    FileLog("httprequest", "LiveChat.Native::SetCookiesInfo(size:%d) end", cookiesList.size());

    }

    /*
     * Class:     com_qpidnetwork_request_RequestJni
     * Method:    SetProxy
     * Signature: (Ljava/lang/String;I)V
     */
    JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetProxy
      (JNIEnv *env, jclass cls, jstring proxyUrl) {
    	string cpProxyUrl = JString2String(env, proxyUrl);
    	FileLog(LIVESHOW_HTTP_LOG, "LShttprequestJNI::SetProxy ( proxyUrl : %s ) ", cpProxyUrl.c_str());

    	HttpClient::SetProxy(cpProxyUrl);

    }

   JNIEXPORT void JNICALL Java_com_qpidnetwork_livemodule_livechathttprequest_LCRequestJni_SetAppId
       (JNIEnv *env, jclass cls, jstring appId) {
	    string cpAppId = JString2String(env, appId);
	    gLSLiveChatHttpRequestManager.SetAppId(cpAppId);
    }