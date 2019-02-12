/*
 * HttpCanSendEmfTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.9.获取主播信件权限
 */

#include "HttpCanSendEmfTask.h"

HttpCanSendEmfTask::HttpCanSendEmfTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CANSENDEMF;

}

HttpCanSendEmfTask::~HttpCanSendEmfTask() {
	// TODO Auto-generated destructor stub
}

void HttpCanSendEmfTask::SetCallback(IRequestCanSendEmfCallback* callback) {
	mpCallback = callback;
}

void HttpCanSendEmfTask::SetParam(
                                  const string& anchorId
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (anchorId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_CANSENDEMF_ANCHOR_ID, anchorId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCanSendEmfTask::SetParam( "
            "task : %p, "
            "anchorId : %s,"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpCanSendEmfTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCanSendEmfTask::ParseData( "
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
    HttpAnchorSendEmfPrivItem item;
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
        mpCallback->OnCanSendEmf(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

