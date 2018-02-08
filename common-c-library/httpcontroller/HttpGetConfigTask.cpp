/*
 * HttpGetConfigTask.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 6.1.同步配置
 */

#include "HttpGetConfigTask.h"

HttpGetConfigTask::HttpGetConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GET_CONFIG;
}

HttpGetConfigTask::~HttpGetConfigTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetConfigTask::SetCallback(IRequestGetConfigCallback* callback) {
	mpCallback = callback;
}

void HttpGetConfigTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetConfigTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetConfigTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetConfigTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpConfigItem item;
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
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetConfig(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

