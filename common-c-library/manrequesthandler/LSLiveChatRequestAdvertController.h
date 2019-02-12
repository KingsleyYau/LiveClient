/*
 * LSLiveChatRequestAdvertController.h
 *
 *  Created on: 2015-04-22
 *      Author: Samson.Fan
 */

#ifndef REQUESTADVERTCONTROLLER_H_
#define REQUESTADVERTCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"
#include "item/LSLCAdvert.h"

typedef void (*OnRequestAdMainAdvert)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCAdMainAdvertItem& item);
typedef void (*OnRequestAdWomanListAdvert)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCAdWomanListAdvertItem& item);
typedef void (*OnRequestAdPushAdvert)(long requestId, bool success, const string& errnum, const string& errmsg, const AdPushAdvertList& pushList);
typedef void (*OnRequestAppPromotionAdvert)(long requestId, bool success, const string& errnum, const string& errmsg, const string& adOverview);
typedef void (*OnRequestPopNoticeAdvert)(long requestId, bool success, const string& errnum, const string& errmsg, const string& url, bool isCanClose);
typedef void (*OnRequestAdmirerListAd)(long requestId, bool success, const string& errnum, const string& errmsg, const string& advertId, const string& htmlCode, const string& advertTitle);
typedef void (*OnRequestHtml5Ad)(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCAdHtml5AdvertItem& item);
typedef struct _tagLSLiveChatRequestAdvertControllerCallback {
	OnRequestAdMainAdvert onRequestAdMainAdvert;
	OnRequestAdWomanListAdvert onRequestAdWomanListAdvert;
	OnRequestAdPushAdvert onRequestAdPushAdvert;
	OnRequestAppPromotionAdvert onRequestAppPromotionAdvert;
    OnRequestPopNoticeAdvert    onRequestPopNoticeAdvert;
    OnRequestAdmirerListAd      onRequestAdmirerListAd;
    OnRequestHtml5Ad            onRequestHtml5Ad;
} LSLiveChatRequestAdvertControllerCallback;


class LSLiveChatRequestAdvertController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestAdvertController(LSLiveChatHttpRequestManager* pHttpRequestManager, const LSLiveChatRequestAdvertControllerCallback& callback);
	virtual ~LSLiveChatRequestAdvertController();

public:
	long MainAdvert(const string& deviceId, const string& advertId, int showTimes, int clickTimes);
	long WomanListAdvert(const string& deviceId, const string& advertId, int showTimes, int clickTimes, AdvertSpaceType adspaceId);
	long PushAdvert(const string& deviceId, const string& pushId);
	long AppPromotionAdvert(const string& deviceId);
    long PopNoticeAdvert(const string& deviceId);
    long AdmirerListAd(const string& deviceId, const string& advertId, long firstGottime, int showTimes, int clickTimes);
    long Html5Ad(const string& deviceId, const string& advertId, long firstGottime, int showTimes, int clickTimes, AdvertHtmlSpaceType adspaceId, const string& adOverview);

private:
	void MainAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void WomanListAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void PushAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
	void AppPromotionCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
    void PopNoticeCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
    void AdmirerListAdCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);
    void Html5AdCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size);

// ILSLiveChatHttpRequestManagerCallback interface
protected:
	virtual void onSuccess(long requestId, string path, const char* buf, int size);
	virtual void onFail(long requestId, string path);

private:
	LSLiveChatRequestAdvertControllerCallback m_Callback;
};

#endif /* REQUESTADVERTCONTROLLER_H_ */
