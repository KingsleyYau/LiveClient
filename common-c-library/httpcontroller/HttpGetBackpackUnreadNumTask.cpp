/*
 * HttpGetBackpackUnreadNumTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.5.获取背包未读数量
 */

#include "HttpGetBackpackUnreadNumTask.h"

HttpGetBackpackUnreadNumTask::HttpGetBackpackUnreadNumTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETBACKPACKUNREADNUM;
}

HttpGetBackpackUnreadNumTask::~HttpGetBackpackUnreadNumTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetBackpackUnreadNumTask::SetCallback(IRequestGetBackpackUnreadNumCallback* callback) {
	mpCallback = callback;
}

void HttpGetBackpackUnreadNumTask::SetParam(
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog("httpcontroller",
            "HttpGetBackpackUnreadNumTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetBackpackUnreadNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetBackpackUnreadNumTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetBackpackUnreadNumTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpGetBackPackUnreadNumItem item;
    bool bParse = false;
    
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
        mpCallback->OnGetBackpackUnreadNum(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

