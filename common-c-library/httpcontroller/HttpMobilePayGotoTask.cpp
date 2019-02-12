/*
 * HttpMobilePayGotoTask.cpp
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 7.7.获取h5买点页面URL（仅Android）
 */

#include "HttpMobilePayGotoTask.h"
#include "HttpRequestConvertEnum.h"

HttpMobilePayGotoTask::HttpMobilePayGotoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_MOBILEPAYGOTO_PATH;
;
}

HttpMobilePayGotoTask::~HttpMobilePayGotoTask() {
	// TODO Auto-generated destructor stub
}

void HttpMobilePayGotoTask::SetCallback(IRequestMobilePayGotoCallback* callback) {
	mpCallback = callback;
}

void HttpMobilePayGotoTask::SetParam(
                                         const string& url,
                                         HTTP_OTHER_SITE_TYPE siteId,
                                         LSOrderType orderType,
                                         const string& clickFrom,
                                         const string& number
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[26];
    
    // siteid
    string strSite("");
    strSite = GetHttpSiteId(siteId);
    
    if (url.length() > 0) {
        snprintf(temp, sizeof(temp), "%s%s", url.c_str(), strSite.c_str());
        mHttpEntiy.AddContent(LIVEROOM_MOBILEPAYGOTO_url, temp);
    }
    
    mHttpEntiy.AddContent(LIVEROOM_MOBILEPAYGOTO_SITEID, strSite);
    
    if (orderType >= LSORDERTYPE_BEGIN && orderType <= LSORDERTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", orderType);
        mHttpEntiy.AddContent(LIVEROOM_MOBILEPAYGOTO_ORDERTYPE, temp);
    }
    
    if (clickFrom.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_MOBILEPAYGOTO_CLICKFROM, clickFrom.c_str());
    }
    
    if (number.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_MOBILEPAYGOTO_NUMBER, number.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpMobilePayGotoTask::SetParam( "
            "task : %p, "
            "url : %s ,"
            "siteId : %s ,"
            "orderType : %d ,"
            "clickFrom : %s ,"
            "number : %s ,"
            ")",
            this,
            url.c_str(),
            strSite.c_str(),
            orderType,
            clickFrom.c_str(),
            number.c_str()
            );
}

bool HttpMobilePayGotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpMobilePayGotoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string redirect = "";
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseNewLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_MOBILEPAYGOTO_REDIRECT].isString()) {
                    redirect = dataJson[LIVEROOM_MOBILEPAYGOTO_REDIRECT].asString();
                }
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnMobilePayGoto(this, bParse, errnum, errmsg, redirect);
    }
    
    return bParse;
}

