/*
 * HttpSendScheduleInviteTask.cpp
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.3.发送预付费直播邀请
 */

#include "HttpSendScheduleInviteTask.h"

HttpSendScheduleInviteTask::HttpSendScheduleInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDSCHEDULELIVEINVITE;
}

HttpSendScheduleInviteTask::~HttpSendScheduleInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendScheduleInviteTask::SetCallback(IRequestSendScheduleInviteCallback* callback) {
	mpCallback = callback;
}

void HttpSendScheduleInviteTask::SetParam(
                                          LSScheduleInviteType type,
                                          string refId,
                                          string anchorId,
                                          string timeZoneId,
                                          string startTime,
                                          int duration
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", GetLSScheduleInviteTypeToInt(type));
    mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_TYPE, temp);
    
    if (refId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_REF_ID, refId.c_str());
    }
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_ANCHOR_ID, anchorId.c_str());
    }
    
    if (timeZoneId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_TIME_ZONE_ID, timeZoneId.c_str());
    }

    if (startTime.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_START_TIME, startTime.c_str());
    }
    
    snprintf(temp, sizeof(temp), "%d", duration);
    mHttpEntiy.AddContent(LIVEROOM_SENDSCHEDULELIVEINVITE_DURATION, temp);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendScheduleInviteTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "refId : %s, "
            "anchorId : %s, "
            "timeZoneId : %s, "
            "startTime : %s, "
            "duration : %d"
            ")",
            this,
            type,
            refId.c_str(),
            anchorId.c_str(),
            timeZoneId.c_str(),
            startTime.c_str(),
            duration
            );
}

bool HttpSendScheduleInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendScheduleInviteTask::ParseData( "
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
    HttpScheduleInviteItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSendScheduleInvite(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

