/*
 * HttpAutoInvitationClickLogTask.cpp
 *
 *  Created on: 2019-1-22
 *      Author: Alex
 *        desc: 8.10.自动邀请hangout点击记录
 */

#include "HttpAutoInvitationClickLogTask.h"

HttpAutoInvitationClickLogTask::HttpAutoInvitationClickLogTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_AUTOINVITATIONCLICKLOG;

}

HttpAutoInvitationClickLogTask::~HttpAutoInvitationClickLogTask() {
	// TODO Auto-generated destructor stub
}

void HttpAutoInvitationClickLogTask::SetCallback(IRequestAutoInvitationClickLogCallback* callback) {
	mpCallback = callback;
}

void HttpAutoInvitationClickLogTask::SetParam(
                                         const string& anchorId
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (anchorId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_AUTOINVITATIONCLICKLOG_ANCHORID, anchorId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAutoInvitationClickLogTask::SetParam( "
            "task : %p, "
            "anchorId : %s,"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpAutoInvitationClickLogTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAutoInvitationClickLogTask::ParseData( "
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
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAutoInvitationClickLog(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

