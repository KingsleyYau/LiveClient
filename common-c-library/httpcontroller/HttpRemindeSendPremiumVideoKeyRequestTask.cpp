/*
 * HttpRemindeSendPremiumVideoKeyRequestTask.cpp
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.5.发送解码锁请求提醒
 */

#include "HttpRemindeSendPremiumVideoKeyRequestTask.h"

HttpRemindeSendPremiumVideoKeyRequestTask::HttpRemindeSendPremiumVideoKeyRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_SENDKEYREQUESTREMINDE_PATH;
    mRequestId = "";

}

HttpRemindeSendPremiumVideoKeyRequestTask::~HttpRemindeSendPremiumVideoKeyRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpRemindeSendPremiumVideoKeyRequestTask::SetCallback(IRequestRemindeSendPremiumVideoKeyRequestCallback* callback) {
	mpCallback = callback;
}

void HttpRemindeSendPremiumVideoKeyRequestTask::SetParam(
                                           const string& requestId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (requestId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_REQUEST_ID, requestId.c_str());
        mRequestId = requestId;
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRemindeSendPremiumVideoKeyRequestTask::SetParam( "
            "task : %p, "
            "requestId : %s "
            ")",
            this,
            requestId.c_str()
            );
}

bool HttpRemindeSendPremiumVideoKeyRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRemindeSendPremiumVideoKeyRequestTask::ParseData( "
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
    long long currentTime = 0;
    int limitSeconds = 0;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].isNumeric()) {
                    currentTime = dataJson[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].asLong();
                }
                
            }
            
        }
        
        if (errDataJson.isObject()) {
            if (errDataJson[LIVEROOM_PREMIUMVIDEO_LIMIT_SECONDS].isNumeric()) {
                limitSeconds = errDataJson[LIVEROOM_PREMIUMVIDEO_LIMIT_SECONDS].asInt();
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnRemindeSendPremiumVideoKeyRequest(this, bParse, errnum, errmsg, mRequestId, currentTime, limitSeconds);
    }
    
    return bParse;
}

