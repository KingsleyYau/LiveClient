/*
 * HttpGetNewFansBaseInfoTask.cpp
 *
 *  Created on: 2017-8-30
 *      Author: Alex
 *        desc: 3.12.获取指定观众信息
 */

#include "HttpGetNewFansBaseInfoTask.h"

HttpGetNewFansBaseInfoTask::HttpGetNewFansBaseInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETNEWFANSBASEINFO;
    mUserId = "";
}

HttpGetNewFansBaseInfoTask::~HttpGetNewFansBaseInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetNewFansBaseInfoTask::SetCallback(IRequestGetNewFansBaseInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetNewFansBaseInfoTask::SetParam(
                                   const string& userId
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( userId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETNEWFANSBASEINFO_USERID, userId.c_str());
        mUserId = userId;
    }

    FileLog("httpcontroller",
            "HttpGetNewFansBaseInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpGetNewFansBaseInfoTask::GetUserId() {
    return mUserId;
}

bool HttpGetNewFansBaseInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetNewFansBaseInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetNewFansBaseInfoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpLiveFansItem item;
    item.userId = mUserId;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetNewFansBaseInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

