/*
 * HttpCancelScheduleInviteTask.cpp
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.6.取消预付费直播邀请
 */

#include "HttpCancelScheduleInviteTask.h"

HttpCancelScheduleInviteTask::HttpCancelScheduleInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDSCHEDULELIVECANCELINVITE;
}

HttpCancelScheduleInviteTask::~HttpCancelScheduleInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpCancelScheduleInviteTask::SetCallback(IRequestCancelScheduleInviteCallback* callback) {
	mpCallback = callback;
}

void HttpCancelScheduleInviteTask::SetParam(
                                          string inviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_INVITE_ID, inviteId.c_str());
    }
    
 
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCancelScheduleInviteTask::SetParam( "
            "task : %p, "
            "inviteId : %s "
            ")",
            this,
            inviteId.c_str()
            );
}

bool HttpCancelScheduleInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCancelScheduleInviteTask::ParseData( "
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
    long long starusUpdateTime = 0;
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
        mpCallback->OnCancelScheduleInvite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

