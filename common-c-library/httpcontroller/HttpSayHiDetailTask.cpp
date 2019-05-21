/*
 * HttpSayHiDetailTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.7.获取SayHi详情(用于观众端获取SayHi详情)
 */

#include "HttpSayHiDetailTask.h"

HttpSayHiDetailTask::HttpSayHiDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SAYHIDETAIL;

}

HttpSayHiDetailTask::~HttpSayHiDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpSayHiDetailTask::SetCallback(IRequestSayHiDetailCallback* callback) {
	mpCallback = callback;
}

void HttpSayHiDetailTask::SetParam(
                                   LSSayHiDetailType type,
                                   const string& sayHiId
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    snprintf(temp, sizeof(temp), "%d", GetLSSayHiDetailTypeWithInt(type));
    mHttpEntiy.AddContent(LIVEROOM_SAYHIDETAIL_SORT, temp);
    
    if (sayHiId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SAYHIDETAIL_SAYHIID, sayHiId.c_str());
    }


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSayHiDetailTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "sayHiId : %s"
            ")",
            this,
            type,
            sayHiId.c_str()
            );
}


bool HttpSayHiDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSayHiDetailTask::ParseData( "
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
    HttpSayHiDetailItem item;
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
        mpCallback->OnSayHiDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

