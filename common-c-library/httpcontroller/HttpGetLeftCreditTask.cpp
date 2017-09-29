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
    
    FileLog("httpcontroller",
            "HttpGetLeftCreditTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetLeftCreditTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLeftCreditTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLeftCreditTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    double credit = 0.0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETCREDIT_CREDIT].isNumeric()) {
                    credit = dataJson[LIVEROOM_GETCREDIT_CREDIT].asDouble();
                }
                
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetLeftCredit(this, bParse, errnum, errmsg, credit);
    }
    
    return bParse;
}

