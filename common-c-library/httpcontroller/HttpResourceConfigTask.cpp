/*
 * HttpResourceConfigTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.1.获取发送SayHi的主题和文本信息
 */

#include "HttpResourceConfigTask.h"

HttpResourceConfigTask::HttpResourceConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_RESOURCECONFIG;

}

HttpResourceConfigTask::~HttpResourceConfigTask() {
	// TODO Auto-generated destructor stub
}

void HttpResourceConfigTask::SetCallback(IRequestResourceConfigCallback* callback) {
	mpCallback = callback;
}

void HttpResourceConfigTask::SetParam(
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpResourceConfigTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpResourceConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpResourceConfigTask::ParseData( "
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
    HttpSayHiResourceConfigItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
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
        mpCallback->OnResourceConfig(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

