/*
 * HttpBannerTask.cpp
 *
 *  Created on: 2017-10-18
 *      Author: Alex
 *        desc: 6.9.获取Hot/Following列表头部广告
 */

#include "HttpBannerTask.h"

HttpBannerTask::HttpBannerTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_BANNER;
}

HttpBannerTask::~HttpBannerTask() {
	// TODO Auto-generated destructor stub
}

void HttpBannerTask::SetCallback(IRequestBannerCallback* callback) {
	mpCallback = callback;
}

void HttpBannerTask::SetParam(
                                   ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBannerTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpBannerTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBannerTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSubmitPhoneVerifyCodeTask::ParseData( buf : %s )", buf);
    }
    
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string bannerName = "";
    string bannerImg = "";
    string bannerLink = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_BANNER_BANNERNAME].isString()) {
                    bannerName = dataJson[LIVEROOM_BANNER_BANNERNAME].asString();
                }
                if (dataJson[LIVEROOM_BANNER_BANNERIMG].isString()) {
                    bannerImg = dataJson[LIVEROOM_BANNER_BANNERIMG].asString();
                }
                if (dataJson[LIVEROOM_BANNER_BANNERLINK].isString()) {
                    bannerLink = dataJson[LIVEROOM_BANNER_BANNERLINK].asString();
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
        mpCallback->OnBanner(this, bParse, errnum, errmsg, bannerImg, bannerLink, bannerName);
    }
    
    return bParse;
}

