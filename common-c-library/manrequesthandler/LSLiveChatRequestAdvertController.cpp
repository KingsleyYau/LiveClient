/*
 * LSLiveChatRequestAdvertController.cpp
 *
 *  Created on: 2015-3-6
 *      Author: Samson.Fan
 */

#include "LSLiveChatRequestAdvertController.h"
#include "LSLiveChatRequestDefine.h"
#include "LSLiveChatRequestEMFDefine.h"
#include "../common/CommonFunc.h"

LSLiveChatRequestAdvertController::LSLiveChatRequestAdvertController(LSLiveChatHttpRequestManager *pHttpRequestManager, const LSLiveChatRequestAdvertControllerCallback& callback)
{
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(pHttpRequestManager);
	m_Callback = callback;
}

LSLiveChatRequestAdvertController::~LSLiveChatRequestAdvertController()
{
	// TODO Auto-generated destructor stub
}

/* ILSLiveChatHttpRequestManagerCallback */
void LSLiveChatRequestAdvertController::onSuccess(long requestId, string url, const char* buf, int size)
{
	FileLog("httprequest", "LSLiveChatRequestAdvertController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestAdvertController::onSuccess(), buf: %s", buf);
	}

	if( url.compare(ADVERT_MAINADVERT_PATH) == 0 ) {
		MainAdvertCallbackHandle(requestId, url, true, buf, size);
	}
	else if( url.compare(ADVERT_WOMANLISTADVERT_PATH) == 0 ) {
		WomanListAdvertCallbackHandle(requestId, url, true, buf, size);
	}
	else if( url.compare(ADVERT_PUSHADVERT_PATH) == 0 ) {
		PushAdvertCallbackHandle(requestId, url, true, buf, size);
	}else if( url.compare(ADVERT_APP_PROMOTION_PATH) == 0 ){
		AppPromotionCallbackHandle(requestId, url, true, buf, size);
    }else if( url.compare(ADVERT_POP_NOTICE_PATH) == 0 ){
        PopNoticeCallbackHandle(requestId, url, true, buf, size);
    }else if( url.compare(ADVERT_ADMIRERLIST_PATH) == 0 ){
        AdmirerListAdCallbackHandle(requestId, url, true, buf, size);
    }else if( url.compare(ADVERT_HTLM5_PATH) == 0 ){
        Html5AdCallbackHandle(requestId, url, true, buf, size);
    }
	FileLog("httprequest", "LSLiveChatRequestAdvertController::onSuccess() end, url:%s", url.c_str());
}

void LSLiveChatRequestAdvertController::onFail(long requestId, string url)
{
	FileLog("httprequest", "LSLiveChatRequestAdvertController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(ADVERT_MAINADVERT_PATH) == 0 ) {
		MainAdvertCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(ADVERT_WOMANLISTADVERT_PATH) == 0 ) {
		WomanListAdvertCallbackHandle(requestId, url, false, NULL, 0);
	}
	else if( url.compare(ADVERT_PUSHADVERT_PATH) == 0 ) {
		PushAdvertCallbackHandle(requestId, url, false, NULL, 0);
	}else if( url.compare(ADVERT_APP_PROMOTION_PATH) == 0 ){
		AppPromotionCallbackHandle(requestId, url, false, NULL, 0);
    }else if( url.compare(ADVERT_POP_NOTICE_PATH) == 0 ){
        PopNoticeCallbackHandle(requestId, url, false, NULL, 0);
    }else if( url.compare(ADVERT_ADMIRERLIST_PATH) == 0 ){
        AdmirerListAdCallbackHandle(requestId, url, false, NULL, 0);
    }else if( url.compare(ADVERT_HTLM5_PATH) == 0 ){
        Html5AdCallbackHandle(requestId, url, false, NULL, 0);
    }
	FileLog("httprequest", "LSLiveChatRequestAdvertController::onFail() end, url:%s", url.c_str());
}

// ----------------------- MainAdvert -----------------------
long LSLiveChatRequestAdvertController::MainAdvert(const string& deviceId, const string& advertId, int showTimes, int clickTimes)
{
	char temp[16];
	HttpEntiy entiy;

	// deviceId
	entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
	// advertId
	if (!advertId.empty()) {
		entiy.AddContent(ADVERT_REQUEST_ADVERTID, advertId);
		// showTimes
		sprintf(temp, "%d", showTimes);
		entiy.AddContent(ADVERT_REQUEST_SHOWTIMES, temp);
		// clickTimes
		sprintf(temp, "%d", clickTimes);
		entiy.AddContent(ADVERT_REQUEST_CLICKTIMES, temp);
	}

	string url = ADVERT_MAINADVERT_PATH;
	FileLog("httprequest", "LSLiveChatRequestAdvertController::MainAdvert"
			"( url:%s, deviceId:%s, advertId:%s, showTimes:%d, clickTimes:%d)",
			url.c_str(), deviceId.c_str(), advertId.c_str(), showTimes, clickTimes);

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::MainAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCAdMainAdvertItem item;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestAdvertController::MainAdvertCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestAdMainAdvert != NULL ) {
		m_Callback.onRequestAdMainAdvert(requestId, bFlag, errnum, errmsg, item);
	}
}

// ----------------------- WomanListAdvert -----------------------
long LSLiveChatRequestAdvertController::WomanListAdvert(const string& deviceId, const string& advertId, int showTimes, int clickTimes, AdvertSpaceType adspaceId)
{
	char temp[16];
	HttpEntiy entiy;

	// deviceId
	entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
	// advertId
	if (!advertId.empty()) {
		entiy.AddContent(ADVERT_REQUEST_ADVERTID, advertId);
		// showTimes
		sprintf(temp, "%d", showTimes);
		entiy.AddContent(ADVERT_REQUEST_SHOWTIMES, temp);
		// clickTimes
		sprintf(temp, "%d", clickTimes);
		entiy.AddContent(ADVERT_REQUEST_CLICKTIMES, temp);
	}
    sprintf(temp, "%d", GetAdvertSpaceTypeToInt(adspaceId));
    entiy.AddContent(ADVERT_REQUEST_ADSPACEID, temp);

	string url = ADVERT_WOMANLISTADVERT_PATH;
	FileLog("httprequest", "LSLiveChatRequestAdvertController::WomanListAdvert"
            "( url:%s, deviceId:%s, advertId:%s, showTimes:%d, clickTimes:%d, adspaceId:%d spaceType:%d)",
			url.c_str(), deviceId.c_str(), advertId.c_str(), showTimes, clickTimes, adspaceId, GetAdvertSpaceTypeToInt(adspaceId));

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::WomanListAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	LSLCAdWomanListAdvertItem item;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson.isObject()) {
				bFlag = item.Parsing(dataJson);
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestAdvertController::WomanListAdvertCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestAdWomanListAdvert != NULL ) {
//        item.advertId = "advertId";
//        item.image = "image";
//        item.height = 15;
//        item.width = 12;
//        item.adurl = "adurl";
//        item.openType = AD_OT_SYSTEMBROWER;
		m_Callback.onRequestAdWomanListAdvert(requestId, bFlag, errnum, errmsg, item);
	}
}

// ----------------------- PushAdvert -----------------------
long LSLiveChatRequestAdvertController::PushAdvert(const string& deviceId, const string& pushId)
{
//	char temp[16];
	HttpEntiy entiy;

	// deviceId
	entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
	// pushId
	if (!pushId.empty()) {
		entiy.AddContent(ADVERT_REQUEST_PUSHID, pushId);
	}

	string url = ADVERT_PUSHADVERT_PATH;
	FileLog("httprequest", "LSLiveChatRequestAdvertController::PushAdvert"
			"( url:%s, deviceId:%s, pushId:%s)",
			url.c_str(), deviceId.c_str(), pushId.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::PushAdvertCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	AdPushAdvertList list;
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson[COMMON_DATA_LIST].isArray()) {
				bFlag = true;

				int i = 0;
				for (i = 0; i < dataJson[COMMON_DATA_LIST].size(); i++) {
					LSLCAdPushAdvertItem item;
					if (item.Parsing(dataJson[COMMON_DATA_LIST].get(i, Json::Value::null))) {
						list.push_back(item);
					}
				}
			}

			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestAdvertController::WomanListAdvertCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestAdPushAdvert != NULL ) {
		m_Callback.onRequestAdPushAdvert(requestId, bFlag, errnum, errmsg, list);
	}
}

// ----------------------- AppPromotionAdvert -----------------------
long LSLiveChatRequestAdvertController::AppPromotionAdvert(const string& deviceId)
{
//	char temp[16];
	HttpEntiy entiy;

	// deviceId
	entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);

	string url = ADVERT_APP_PROMOTION_PATH;
	FileLog("httprequest", "LSLiveChatRequestAdvertController::AppPromotionAdvert"
			"( url:%s, deviceId:%s)",url.c_str(), deviceId.c_str());

	return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::AppPromotionCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
	string adOverview = "";
	string errnum = "";
	string errmsg = "";
	bool bFlag = false;

	if (requestRet) {
		// request success
		Json::Value dataJson;
		if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
			if (dataJson[ADVERT_ADOVERVIEW].isString()) {
				adOverview = dataJson[ADVERT_ADOVERVIEW].asString();
				bFlag = true;
			}
			if (!bFlag) {
				// parsing fail
				errnum = LOCAL_ERROR_CODE_PARSEFAIL;
				errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;

				FileLog("httprequest", "LSLiveChatRequestAdvertController::AppPromotionCallbackHandle() parsing fail:"
						"(url:%s, size:%d, buf:%s)",
						url.c_str(), size, buf);
			}
		}
	}
	else {
		// request fail
		errnum = LOCAL_ERROR_CODE_TIMEOUT;
		errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
	}

	if( m_Callback.onRequestAppPromotionAdvert != NULL ) {
		m_Callback.onRequestAppPromotionAdvert(requestId, bFlag, errnum, errmsg, adOverview);
	}
}

// ----------------------- popNoticeAdvert -----------------------
long LSLiveChatRequestAdvertController::PopNoticeAdvert(const string& deviceId)
{
    //	char temp[16];
    HttpEntiy entiy;
    
    // deviceId
    entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
    
    string url = ADVERT_POP_NOTICE_PATH;
    FileLog("httprequest", "LSLiveChatRequestAdvertController::PopNoticeAdvert"
            "( url:%s, deviceId:%s)",url.c_str(), deviceId.c_str());
    
    return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::PopNoticeCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
    string noticeUrl = "";
    string errnum = "";
    string errmsg = "";
    bool isCanClose = false;
    bool bFlag = false;
    
    if (requestRet) {
        // request success
        Json::Value dataJson;
        if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[ADVERT_NOTICEURL].isString()) {
                noticeUrl = dataJson[ADVERT_NOTICEURL].asString();
            }
            if (dataJson[ADVERT_CANCLOSE].isInt()) {
                isCanClose = dataJson[ADVERT_CANCLOSE].asInt() == 0 ? false : true;
                bFlag = true;
            }
            if (!bFlag) {
                // parsing fail
                errnum = LOCAL_ERROR_CODE_PARSEFAIL;
                errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
                
                FileLog("httprequest", "LSLiveChatRequestAdvertController::PopNoticeCallbackHandle() parsing fail:"
                        "(url:%s, size:%d, buf:%s)",
                        url.c_str(), size, buf);
            }
        }
    }
    else {
        // request fail
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( m_Callback.onRequestPopNoticeAdvert != NULL ) {
        m_Callback.onRequestPopNoticeAdvert(requestId, bFlag, errnum, errmsg, noticeUrl, isCanClose);
    }
}

// ----------------------- AdmirerListAd -----------------------
long LSLiveChatRequestAdvertController::AdmirerListAd(const string& deviceId, const string& advertId, long firstGottime, int showTimes, int clickTimes)
{
    char temp[16];
    HttpEntiy entiy;
    
    // deviceId
    entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
    // advertId
    if (!advertId.empty()) {
        entiy.AddContent(ADVERT_REQUEST_ADVERTID, advertId);
        // firstGottime
        sprintf(temp, "%ld", firstGottime);
        entiy.AddContent(ADVERT_REQUEST_FIRSTGOTTIME, temp);
        // showTimes
        sprintf(temp, "%d", showTimes);
        entiy.AddContent(ADVERT_REQUEST_SHOWTIMES, temp);
        // clickTimes
        sprintf(temp, "%d", clickTimes);
        entiy.AddContent(ADVERT_REQUEST_CLICKTIMES, temp);
    }
    
    
    string url = ADVERT_ADMIRERLIST_PATH;
    FileLog("httprequest", "LSLiveChatRequestAdvertController::AdmirerListAd"
            "( url:%s, deviceId:%s, advertId:%s, showTimes:%d, clickTimes:%d, firstGottime:%ld)",
            url.c_str(), deviceId.c_str(), advertId.c_str(), showTimes, clickTimes, firstGottime);
    
    return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::AdmirerListAdCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
    string advertId = "";
    string errnum = "";
    string errmsg = "";
    string htmlCode = "";
    string advertTitle = "";
    bool bFlag = false;
    
    if (requestRet) {
        // request success
        Json::Value dataJson;
        if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[ADVERT_ADVERTID].isString()) {
                advertId = dataJson[ADVERT_ADVERTID].asString();
               
            }
            if (dataJson[ADVERT_HTMLCODE].isString()) {
                htmlCode = dataJson[ADVERT_HTMLCODE].asString();
            }
            
            if (dataJson[ADVERT_ADVERTTITLE].isString()) {
                advertTitle = dataJson[ADVERT_ADVERTTITLE].asString();
            }
            
            
            if (errnum.length() <= 0) {
                bFlag = true;
            }
            if (!bFlag) {
                // parsing fail
                errnum = LOCAL_ERROR_CODE_PARSEFAIL;
                errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
                
                FileLog("httprequest", "LSLiveChatRequestAdvertController::AdmirerListAdCallbackHandle() parsing fail:"
                        "(url:%s, size:%d, buf:%s)",
                        url.c_str(), size, buf);
            }
        }
    }
    else {
        // request fail
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( m_Callback.onRequestAdmirerListAd != NULL ) {
        m_Callback.onRequestAdmirerListAd(requestId, bFlag, errnum, errmsg, advertId, htmlCode, advertTitle);
    }
}

//// ----------------------- AdmirerListAd -----------------------
long LSLiveChatRequestAdvertController::Html5Ad(const string& deviceId, const string& advertId, long firstGottime, int showTimes, int clickTimes, AdvertHtmlSpaceType adspaceId, const string& adOverview)
{
    char temp[16];
    HttpEntiy entiy;

    // deviceId
    entiy.AddContent(ADVERT_REQUEST_DEVICEID, deviceId);
    // advertId
    if (!advertId.empty()) {
        entiy.AddContent(ADVERT_REQUEST_ADVERTID, advertId);
        // firstGottime
        sprintf(temp, "%ld", firstGottime);
        entiy.AddContent(ADVERT_REQUEST_FIRSTGOTTIME, temp);
        // showTimes
        sprintf(temp, "%d", showTimes);
        entiy.AddContent(ADVERT_REQUEST_SHOWTIMES, temp);
        // clickTimes
        sprintf(temp, "%d", clickTimes);
        entiy.AddContent(ADVERT_REQUEST_CLICKTIMES, temp);
    }

    sprintf(temp, "%d", GetAdvertHtmlSpaceTypeToInt(adspaceId));
    entiy.AddContent(ADVERT_REQUEST_ADSPACEID, temp);
    
    if (!adOverview.empty()) {
        entiy.AddContent(ADVERT_REQUEST_ADOVERVIEW, adOverview);
    }

    string url = ADVERT_HTLM5_PATH;
    FileLog("httprequest", "LSLiveChatRequestAdvertController::AdmirerListAd"
            "( url:%s, deviceId:%s, advertId:%s, showTimes:%d, clickTimes:%d, firstGottime:%ld, adspaceId:%d spaceType:%d)",
            url.c_str(), deviceId.c_str(), advertId.c_str(), showTimes, clickTimes, firstGottime, adspaceId, GetAdvertHtmlSpaceTypeToInt(adspaceId));

    return StartRequest(url, entiy, this);
}

void LSLiveChatRequestAdvertController::Html5AdCallbackHandle(long requestId, const string& url, bool requestRet, const char* buf, int size)
{
    LSLCAdHtml5AdvertItem item;
    string errnum = "";
    string errmsg = "";
    bool bFlag = false;
    
    if (requestRet) {
        // request success
        Json::Value dataJson;
        if( HandleResult(buf, size, errnum, errmsg, &dataJson) ) {

            if (dataJson.isObject()) {
                item.Parsing(dataJson);
            }
            
            if (errnum.length() <= 0) {
                bFlag = true;
            }
            if (!bFlag) {
                // parsing fail
                errnum = LOCAL_ERROR_CODE_PARSEFAIL;
                errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
                
                FileLog("httprequest", "LSLiveChatRequestAdvertController::AdmirerListAdCallbackHandle() parsing fail:"
                        "(url:%s, size:%d, buf:%s)",
                        url.c_str(), size, buf);
            }
        }
    }
    else {
        // request fail
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( m_Callback.onRequestAdmirerListAd != NULL ) {
        m_Callback.onRequestHtml5Ad(requestId, bFlag, errnum, errmsg, item);
    }
}
