/*
 * HttpIsCanSendSayHiTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.3.检测能否对指定主播发送SayHi（用于检测能否对指定主播发送SayHi）
 */

#include "HttpIsCanSendSayHiTask.h"

HttpIsCanSendSayHiTask::HttpIsCanSendSayHiTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ISCANSENDSAYHI;

}

HttpIsCanSendSayHiTask::~HttpIsCanSendSayHiTask() {
	// TODO Auto-generated destructor stub
}

void HttpIsCanSendSayHiTask::SetCallback(IRequestIsCanSendSayHiCallback* callback) {
	mpCallback = callback;
}

void HttpIsCanSendSayHiTask::SetParam(
                                      const string& anchorId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ISCANSENDSAYHI_ANCHORID, anchorId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIsCanSendSayHiTask::SetParam( "
            "task : %p, "
            "anchorId : %s"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpIsCanSendSayHiTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIsCanSendSayHiTask::ParseData( "
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
    bool isCanSend = false;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_ISCANSENDSAYHI_RESULT].isNumeric()) {
                    isCanSend = dataJson[LIVEROOM_ISCANSENDSAYHI_RESULT].asInt() == 1 ? true : false;
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
        mpCallback->OnIsCanSendSayHi(this, bParse, errnum, errmsg, isCanSend);
    }
    
    return bParse;
}

