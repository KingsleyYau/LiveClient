/*
 * HttpCancelInviteHangoutTask.cpp
 *
 *  Created on: 2018-4-13
 *      Author: Alex
 *        desc: 8.3.取消多人互动邀请
 */

#include "HttpCancelInviteHangoutTask.h"

HttpCancelInviteHangoutTask::HttpCancelInviteHangoutTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CANCELHANGOUTINVIT;
    mInviteId = "";

}

HttpCancelInviteHangoutTask::~HttpCancelInviteHangoutTask() {
	// TODO Auto-generated destructor stub
}

void HttpCancelInviteHangoutTask::SetCallback(IRequestCancelInviteHangoutCallback* callback) {
	mpCallback = callback;
}

void HttpCancelInviteHangoutTask::SetParam(
                                             const string& inviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( inviteId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_CANCELHANGOUTINVIT_INVITEID, inviteId.c_str());
        mInviteId = inviteId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCancelInviteHangoutTask::SetParam( "
            "task : %p, "
            "inviteId : %s"
            ")",
            this,
            inviteId.c_str()
            );
}

bool HttpCancelInviteHangoutTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCancelInviteHangoutTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpCancelInviteHangoutTask::ParseData( buf : %s )", buf);
    }
    

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
        mpCallback->OnCancelInviteHangout(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

