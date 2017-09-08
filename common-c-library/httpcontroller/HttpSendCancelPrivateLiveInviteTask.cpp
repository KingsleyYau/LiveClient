/*
 * HttpSendCancelPrivateLiveInviteTask.cpp
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *        desc: 4.3.取消预约邀请
 */

#include "HttpSendCancelPrivateLiveInviteTask.h"

HttpSendCancelPrivateLiveInviteTask::HttpSendCancelPrivateLiveInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDCANCELPRIVATELIVEINVITE;
    mInvitationId = "";
}

HttpSendCancelPrivateLiveInviteTask::~HttpSendCancelPrivateLiveInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendCancelPrivateLiveInviteTask::SetCallback(IRequestSendCancelPrivateLiveInviteCallback* callback) {
	mpCallback = callback;
}


void HttpSendCancelPrivateLiveInviteTask::SetParam(
                                            string invitationId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (invitationId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDCANCELPRIVATELIVEINVITE_INVITATIONID, invitationId.c_str());
        mInvitationId = invitationId;
    }
 
    
    FileLog("httpcontroller",
            "HttpSendCancelPrivateLiveInviteTask::SetParam( "
            "task : %p, "
            "invitationId :%s, "
            ")",
            this,
            invitationId.c_str()
            );
}


string HttpSendCancelPrivateLiveInviteTask::GetInvitationId() {
    return mInvitationId;
}


bool HttpSendCancelPrivateLiveInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpSendCancelPrivateLiveInviteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpSendCancelPrivateLiveInviteTask::ParseData( buf : %s )", buf);
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
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSendCancelPrivateLiveInvite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

