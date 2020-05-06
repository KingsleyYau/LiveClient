/*
 * HttpDeclinedScheduleInviteTask.cpp
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.5.拒绝预付费直播邀请
 */

#include "HttpDeclinedScheduleInviteTask.h"

HttpDeclinedScheduleInviteTask::HttpDeclinedScheduleInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDSCHEDULELIVEDELINEDINVITE;
}

HttpDeclinedScheduleInviteTask::~HttpDeclinedScheduleInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpDeclinedScheduleInviteTask::SetCallback(IRequestDeclinedScheduleInviteCallback* callback) {
	mpCallback = callback;
}

void HttpDeclinedScheduleInviteTask::SetParam(
                                          string inviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_INVITE_ID, inviteId.c_str());
    }
    
 
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDeclinedScheduleInviteTask::SetParam( "
            "task : %p, "
            "inviteId : %s "
            ")",
            this,
            inviteId.c_str()
            );
}

bool HttpDeclinedScheduleInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDeclinedScheduleInviteTask::ParseData( "
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
            if (dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].isNumeric()) {
                starusUpdateTime = dataJson[LIVEROOM_SENDSCHEDULELIVEACCEPTINVITE_STATUSUPDATETIME].asLong();
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnDeclinedScheduleInvite(this, bParse, errnum, errmsg, starusUpdateTime);
    }
    
    return bParse;
}

