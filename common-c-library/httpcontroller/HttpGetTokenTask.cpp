/*
 * HttpGetTokenTask.cpp
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.19.获取认证token
 */

#include "HttpGetTokenTask.h"
#include "HttpRequestConvertEnum.h"

HttpGetTokenTask::HttpGetTokenTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETTOKEN_PATH;
}

HttpGetTokenTask::~HttpGetTokenTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetTokenTask::SetCallback(IRequestGetTokenCallback* callback) {
	mpCallback = callback;
}

void HttpGetTokenTask::SetParam(
                                const string& url,
                                HTTP_OTHER_SITE_TYPE siteId
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[26] = {0};
    
    // siteid
    string strSite("");
    strSite = GetHttpSiteId(siteId);
    
    if (url.length() > 0) {
        snprintf(temp, sizeof(temp), "%s%s", url.c_str(), strSite.c_str());
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_URL, temp);
    }
    

    mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_SITEID, strSite);

    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetTokenTask::SetParam( "
            "task : %p, "
            "url : %s"
            "siteId : %d"
            ")",
            this,
            url.c_str(),
            siteId
            );
}

bool HttpGetTokenTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetTokenTask::ParseData( "
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
    string memberId = "";
    string sid = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseNewLiveCommon(buf, size, errnum, errmsg, &dataJson);
        if(bParse) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_DOLOGIN_MEMBERID].isString()) {
                    memberId = dataJson[LIVEROOM_DOLOGIN_MEMBERID].asString();
                }
                if (dataJson[LIVEROOM_DOLOGIN_SID].isString()) {
                    sid = dataJson[LIVEROOM_DOLOGIN_SID].asString();
                }
            }
        }
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetToken(this, bParse, errnum, errmsg, memberId, sid);
    }
    
    return bParse;
}

