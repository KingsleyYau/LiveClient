/*
 * LSLiveChatRequestOtherController.h
 *
 *  Created on: 2015-3-6
 *      Author: Samson.Fan
 */

#ifndef LSLIVECHATREQUESTOTHERCONTROLLER_H_
#define LSLIVECHATREQUESTOTHERCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"
#include "item/LSLCOther.h"

class ILSLiveChatRequestOtherControllerCallback
{
public:
	ILSLiveChatRequestOtherControllerCallback() {}
	virtual ~ILSLiveChatRequestOtherControllerCallback() {}
public:
	virtual void OnEmotionConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherEmotionConfigItem& item) {};
	virtual void OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherGetCountItem& item) {};
	virtual void OnPhoneInfo(long requestId, bool success, const string& errnum, const string& errmsg) {};
	virtual void OnIntegralCheck(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherIntegralCheckItem& item) {};
	virtual void OnVersionCheck(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherVersionCheckItem& item) {};
	virtual void OnSynConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherSynConfigItem& item) {};
	virtual void OnOnlineCount(long requestId, bool success, const string& errnum, const string& errmsg, const OtherOnlineCountList& countList) {};
	virtual void OnUploadCrashLog(long requestId, bool success, const string& errnum, const string& errmsg) {};
	virtual void OnInstallLogs(long requestId, bool success, const string& errnum, const string& errmsg) {};
    // 直播http接口6.2.获取帐号余额
    virtual void OnGetLeftCredit(long requestId, bool success, int errnum, const string& errmsg, double credit, int coupon) {};
};


class LSLiveChatRequestOtherController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestOtherController(LSLiveChatHttpRequestManager* pHttpRequestManager, ILSLiveChatRequestOtherControllerCallback* callback);
	virtual ~LSLiveChatRequestOtherController();

public:
	long EmotionConfig();
	long GetCount(bool money, bool coupon, bool regStep, bool allowAlbum, bool admirerUr, bool integral);
	long PhoneInfo(const string& manId, int verCode, const string& verName, int action, OTHER_SITE_TYPE siteId
			, double density, int width, int height, const string& densityDpi, const string& model, const string& manufacturer, const string& os
			, const string& release, const string& sdk, const string& language, const string& region
			, const string& lineNumber, const string& simOptName, const string& simOpt, const string& simCountryIso, const string& simState
			, int phoneType, int networkType, const string& deviceId);
	long IntegralCheck(const string& womanId);
	long VersionCheck(int currVer, string appId);
	long SynConfig();
	long OnlineCount(int site);
	long UploadCrashLog(const string& deviceId, const string& file);
	long InstallLogs(const string& deviceId, long installtime, long submittime, int verCode
			, const string& model, const string& manufacturer, const string& os, const string& release
			, const string& sdk, int width, int height, const string& referrer, bool isSimulator, const string& checkInfo);
    long GetLeftCredit();

private:
	void EmotionConfigCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void GetCountCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void PhoneInfoCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void IntegralCheckCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void VersionCheckCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void SynConfigCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void OnlineCountCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void UploadCrashLogCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void InstallLogsCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
    void GetLeftCreditCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	ILSLiveChatRequestOtherControllerCallback* m_Callback;
};

#endif /* LSLIVECHATREQUESTOTHERCONTROLLER_H_ */
