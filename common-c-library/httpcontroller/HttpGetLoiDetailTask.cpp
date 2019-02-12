/*
 * HttpGetLoiDetailTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.2.获取意向信详情
 */

#include "HttpGetLoiDetailTask.h"

HttpGetLoiDetailTask::HttpGetLoiDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_GETLOIDETAIL;

}

HttpGetLoiDetailTask::~HttpGetLoiDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLoiDetailTask::SetCallback(IRequestGetLoiDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetLoiDetailTask::SetParam(
                                  string loiId
                                  ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if (loiId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_LOI_ID, loiId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetLoiDetailTask::SetParam( "
            "task : %p, "
            "loiId : %s"
            ")",
            this,
            loiId.c_str()
            );
}


bool HttpGetLoiDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetLoiDetailTask::ParseData( "
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
    HttpDetailLoiItem item;
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
        mpCallback->OnGetLoiDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

