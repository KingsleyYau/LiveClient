/*
 * HttpDealKnockRequestTask.cpp
 *
 *  Created on: 2018-4-13
 *      Author: Alex
 *        desc: 8.5.同意主播敲门请求
 */

#include "HttpDealKnockRequestTask.h"

HttpDealKnockRequestTask::HttpDealKnockRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_DEALKNOCKREQUEST;
    mKnockId = "";

}

HttpDealKnockRequestTask::~HttpDealKnockRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpDealKnockRequestTask::SetCallback(IRequestDealKnockRequestCallback* callback) {
	mpCallback = callback;
}

void HttpDealKnockRequestTask::SetParam(
                                             const string& knockId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( knockId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_DEALKNOCKREQUEST_KNOCKID, knockId.c_str());
        mKnockId = knockId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDealKnockRequestTask::SetParam( "
            "task : %p, "
            "knockId : %s"
            ")",
            this,
            knockId.c_str()
            );
}

bool HttpDealKnockRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDealKnockRequestTask::ParseData( "
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
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
 
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnDealKnockRequest(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

