/*
 * HttpAcceptScheduleInviteTask.cpp
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.4.接受预付费直播邀请
 */

#include "HttpAcceptScheduleInviteTask.h"

HttpAcceptScheduleInviteTask::HttpAcceptScheduleInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE;
    mduration = 0;
}

HttpAcceptScheduleInviteTask::~HttpAcceptScheduleInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpAcceptScheduleInviteTask::SetCallback(IRequestAcceptScheduleInviteCallback* callback) {
	mpCallback = callback;
}

void HttpAcceptScheduleInviteTask::SetParam(
                                          string inviteId,
                                          int duration
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_INVITE_ID, inviteId.c_str());
    }
    
    snprintf(temp, sizeof(temp), "%d", duration);
    mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_DURATION, temp);
    mduration = duration;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAcceptScheduleInviteTask::SetParam( "
            "task : %p, "
            "inviteId : %s, "
            "duration : %d"
            ")",
            this,
            inviteId.c_str(),
            duration
            );
}

bool HttpAcceptScheduleInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAcceptScheduleInviteTask::ParseData( "
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
        //ParseLiveCommon(buf, size, errnum, errmsg, &dataJson);
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].isNumeric()) {
                    starusUpdateTime = dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].asLong();
                }
            }
            
        } else {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].isNumeric()) {
                    starusUpdateTime = dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].asLong();
                }
                if (dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_DURATION].isNumeric()) {
                    mduration = dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_DURATION].asInt();
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
        mpCallback->OnAcceptScheduleInvite(this, bParse, errnum, errmsg, starusUpdateTime, mduration);
    }
    
    return bParse;
}

