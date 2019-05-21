/*
 * HttpSendSayHiTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.4.发送sayHi
 */

#include "HttpSendSayHiTask.h"

HttpSendSayHiTask::HttpSendSayHiTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDSAYHI;

}

HttpSendSayHiTask::~HttpSendSayHiTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendSayHiTask::SetCallback(IRequestSendSayHiCallback* callback) {
	mpCallback = callback;
}

void HttpSendSayHiTask::SetParam(
                                 const string& anchorId,
                                 const string& themeId,
                                 const string& textId
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSAYHI_ANCHORID, anchorId.c_str());
    }
    
    if (themeId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSAYHI_THEMEID, themeId.c_str());
    }
    
    if (textId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSAYHI_TEXTID, textId.c_str());
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendSayHiTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "themeId : %s, "
            "textId : %s"
            ")",
            this,
            anchorId.c_str(),
            themeId.c_str(),
            textId.c_str()
            );
}


bool HttpSendSayHiTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendSayHiTask::ParseData( "
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
    string sayHiId = "";
    string sayHiOrLoiId = "";
    bool bParse = false;
    bool isFollow = false;
    OnLineStatus onlineStatus = ONLINE_STATUS_OFFLINE;
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_SENDSAYHI_SAYHIID].isString()) {
                    sayHiId = dataJson[LIVEROOM_SENDSAYHI_SAYHIID].asString();
                }
                /* onlineStatus */
                if (dataJson[LIVEROOM_SENDSAYHI_ONLINESTATUS].isNumeric()) {
                    onlineStatus = GetIntToOnLineStatus(dataJson[LIVEROOM_SENDSAYHI_ONLINESTATUS].asInt());
                }
            }
            
        } else {
            if (errDataJson.isObject()) {
                if( errDataJson[LIVEROOM_SENDSAYHI_ID].isString()) {
                    sayHiOrLoiId = errDataJson[LIVEROOM_SENDSAYHI_ID].asString();
                }
                if ( errDataJson[LIVEROOM_SENDSAYHI_HASFOLLOW].isNumeric()) {
                    isFollow = errDataJson[LIVEROOM_SENDSAYHI_HASFOLLOW].asInt() == 0 ? false : true;
                }
                /* onlineStatus */
                if (errDataJson[LIVEROOM_SENDSAYHI_ONLINESTATUS].isNumeric()) {
                    onlineStatus = GetIntToOnLineStatus(errDataJson[LIVEROOM_SENDSAYHI_ONLINESTATUS].asInt());
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
        mpCallback->OnSendSayHi(this, bParse, errnum, errmsg, sayHiId, sayHiOrLoiId, isFollow, onlineStatus);
    }
    
    return bParse;
}

