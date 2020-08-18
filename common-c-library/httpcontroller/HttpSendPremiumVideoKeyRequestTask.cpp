/*
 * HttpSendPremiumVideoKeyRequestTask.cpp
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.4.发送解码锁请求
 */

#include "HttpSendPremiumVideoKeyRequestTask.h"

HttpSendPremiumVideoKeyRequestTask::HttpSendPremiumVideoKeyRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_SENDKEYREQUEST_PATH;
    mVideoId = "";

}

HttpSendPremiumVideoKeyRequestTask::~HttpSendPremiumVideoKeyRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendPremiumVideoKeyRequestTask::SetCallback(IRequestSendPremiumVideoKeyRequestCallback* callback) {
	mpCallback = callback;
}

void HttpSendPremiumVideoKeyRequestTask::SetParam(
                                           const string& videoId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (videoId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_VIDEO_ID, videoId.c_str());
        mVideoId = videoId;
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendPremiumVideoKeyRequestTask::SetParam( "
            "task : %p, "
            "videoId : %s "
            ")",
            this,
            videoId.c_str()
            );
}

bool HttpSendPremiumVideoKeyRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendPremiumVideoKeyRequestTask::ParseData( "
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
    string requestId = "";
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].isString()) {
                    requestId = dataJson[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].asString();
                }
            }
            
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSendPremiumVideoKeyRequest(this, bParse, errnum, errmsg, mVideoId, requestId);
    }
    
    return bParse;
}

