/*
 * HttpVersionCheckTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 6.20.检查客户端更新
 */

#include "HttpVersionCheckTask.h"

HttpVersionCheckTask::HttpVersionCheckTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_VERSIONCHECK;


}

HttpVersionCheckTask::~HttpVersionCheckTask() {
	// TODO Auto-generated destructor stub
}

void HttpVersionCheckTask::SetCallback(IRequestVersionCheckCallback* callback) {
	mpCallback = callback;
}

void HttpVersionCheckTask::SetParam(
                                      int currVersion
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16] = {0};
    
    snprintf(temp, sizeof(temp), "%d", currVersion);
    mHttpEntiy.AddContent(LIVEROOM_VERSIONCHECK_CURRVERSION, temp);

    


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpVersionCheckTask::SetParam( "
            "task : %p, "
            "currVersion:%d,"
            ")",
            this,
            currVersion
            );
}



bool HttpVersionCheckTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpVersionCheckTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    bool bParse = false;
    HttpVersionCheckItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if( bParse) {
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
        }
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnVersionCheck(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

