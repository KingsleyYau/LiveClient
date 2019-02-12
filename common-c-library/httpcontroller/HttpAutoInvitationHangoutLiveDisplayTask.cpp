/*
 * HttpAutoInvitationHangoutLiveDisplayTask.cpp
 *
 *  Created on: 2019-1-22
 *      Author: Alex
 *        desc: 8.9.自动邀请Hangout直播邀請展示條件
 */

#include "HttpAutoInvitationHangoutLiveDisplayTask.h"

HttpAutoInvitationHangoutLiveDisplayTask::HttpAutoInvitationHangoutLiveDisplayTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_AUTOINVITATIONHANGOUTLIVEDISPLAY;

}

HttpAutoInvitationHangoutLiveDisplayTask::~HttpAutoInvitationHangoutLiveDisplayTask() {
	// TODO Auto-generated destructor stub
}

void HttpAutoInvitationHangoutLiveDisplayTask::SetCallback(IRequestAutoInvitationHangoutLiveDisplayCallback* callback) {
	mpCallback = callback;
}

void HttpAutoInvitationHangoutLiveDisplayTask::SetParam(
                                         const string& anchorId
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (anchorId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_AUTOINVITATIONHANGOUTLIVEDISPLAY_ANCHORID, anchorId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAutoInvitationHangoutLiveDisplayTask::SetParam( "
            "task : %p, "
            "anchorId : %s,"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpAutoInvitationHangoutLiveDisplayTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAutoInvitationHangoutLiveDisplayTask::ParseData( "
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
        mpCallback->OnAutoInvitationHangoutLiveDisplay(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

