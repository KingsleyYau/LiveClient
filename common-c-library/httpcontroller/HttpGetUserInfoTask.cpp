/*
 * HttpBannerTask.cpp
 *
 *  Created on: 2017-11-01
 *      Author: Alex
 *        desc: 6.10.获取主播/观众信息
 */

#include "HttpGetUserInfoTask.h"

HttpGetUserInfoTask::HttpGetUserInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETUSERINFO;
    mUserId = "";
}

HttpGetUserInfoTask::~HttpGetUserInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetUserInfoTask::SetCallback(IRequestGetUserInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetUserInfoTask::SetParam(
                                   const string& userId
                                   ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (userId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETUSERINFO_USERID, userId.c_str());
        mUserId = userId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "LSHttpGetUserInfoTask::SetParam( "
            "task : %p, "
            "userId: %s"
            ")",
            this,
            userId.c_str()
            );
}

const string& HttpGetUserInfoTask::GetUserId() {
    return mUserId;
}


bool HttpGetUserInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "LSHttpGetUserInfoTask::ParseData( "
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
    HttpUserInfoItem item;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetUserInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

