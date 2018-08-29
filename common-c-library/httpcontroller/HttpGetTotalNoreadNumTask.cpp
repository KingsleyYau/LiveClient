/*
 * HttpGetTotalNoreadNumTask.cpp
 *
 *  Created on: 2018-6-22
 *      Author: Alex
 *        desc: 6.17.获取私信消息列表
 */

#include "HttpGetTotalNoreadNumTask.h"

HttpGetTotalNoreadNumTask::HttpGetTotalNoreadNumTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETTOTALNOREADNUM;
}

HttpGetTotalNoreadNumTask::~HttpGetTotalNoreadNumTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetTotalNoreadNumTask::SetCallback(IRequestGetTotalNoreadNumCallback* callback) {
	mpCallback = callback;
}

void HttpGetTotalNoreadNumTask::SetParam(
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetTotalNoreadNumTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetTotalNoreadNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetTotalNoreadNumTask::ParseData( "
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
    HttpMainNoReadNumItem item;
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
        mpCallback->OnGetTotalNoreadNum(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

