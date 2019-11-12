/*
 * HttpRetrieveBannerTask.cpp
 *
 *  Created on: 2019-08-08
 *      Author: Alex
 *        desc: 6.24.获取直播广告
 */

#include "HttpRetrieveBannerTask.h"

HttpRetrieveBannerTask::HttpRetrieveBannerTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_RETRIEVEBANNER;

}

HttpRetrieveBannerTask::~HttpRetrieveBannerTask() {
	// TODO Auto-generated destructor stub
}

void HttpRetrieveBannerTask::SetCallback(IRequestRetrieveBannerCallback* callback) {
	mpCallback = callback;
}

void HttpRetrieveBannerTask::SetParam(
                                      string manId,
                                      bool isAnchorPage,
                                      LSBannerType bannerType
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (manId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_RETRIEVEBANNER_USERID, manId.c_str());
    }
    
    snprintf(temp, sizeof(temp), "%d", isAnchorPage == true ? 1 : 0 );
    mHttpEntiy.AddContent(LIVEROOM_RETRIEVEBANNER_ISANCHORPAGE, temp);
    
    if (bannerType > LSBANNERTYPE_BEGIN && bannerType <= LSBANNERTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", bannerType );
        mHttpEntiy.AddContent(LIVEROOM_RETRIEVEBANNER_PAGEID, temp);
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRetrieveBannerTask::SetParam( "
            "task : %p, "
            "manId : %s,"
            "isAnchorPage : %d,"
            "bannerType : %d"
            ")",
            this,
            manId.c_str(),
            isAnchorPage,
            bannerType
            );
}


bool HttpRetrieveBannerTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRetrieveBannerTask::ParseData( "
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
    string htmlUrl = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isString()) {
                htmlUrl = dataJson.asString();
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnRetrieveBanner(this, bParse, errnum, errmsg, htmlUrl);
    }
    
    return bParse;
}

