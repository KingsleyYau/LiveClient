/*
 * HttpReadResponseTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.8.获取SayHi回复详情
 */

#include "HttpReadResponseTask.h"

HttpReadResponseTask::HttpReadResponseTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_READRESPONSE;

}

HttpReadResponseTask::~HttpReadResponseTask() {
	// TODO Auto-generated destructor stub
}

void HttpReadResponseTask::SetCallback(IRequestReadResponseCallback* callback) {
	mpCallback = callback;
}

void HttpReadResponseTask::SetParam(
                                    const string& sayHiId,
                                    const string& responseId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (sayHiId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_READRESPONSE_SAYHIID, sayHiId.c_str());
    }
    if (responseId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_READRESPONSE_RESPONSEID, responseId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpReadResponseTask::SetParam( "
            "task : %p, "
            "sayHiId : %s, "
            "responseId : %s"
            ")",
            this,
            sayHiId.c_str(),
            responseId.c_str()
            );
}


bool HttpReadResponseTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpReadResponseTask::ParseData( "
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
    HttpSayHiDetailItem::ResponseSayHiDetailItem responseItem;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
                responseItem.Parse(dataJson);
            }
            
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnReadResponse(this, bParse, errnum, errmsg, responseItem);
    }
    
    return bParse;
}

