/*
 * HttpGetLeftCreditTask.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 6.2.获取账号余额
 */

#include "HttpGetLeftCreditTask.h"

HttpGetLeftCreditTask::HttpGetLeftCreditTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GET_LEFTCREDIT;
}

HttpGetLeftCreditTask::~HttpGetLeftCreditTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLeftCreditTask::SetCallback(IRequestGetLeftCreditCallback* callback) {
	mpCallback = callback;
}

void HttpGetLeftCreditTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetLeftCreditTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetLeftCreditTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetLeftCreditTask::ParseData( "
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
    HttpLeftCreditItem item;
    bool bParse = false;
    
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
        mpCallback->OnGetLeftCredit(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

