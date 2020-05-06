/*
 * HttpGetScheduleInviteDetailTask.cpp
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.8.获取预付费直播邀请详情
 */

#include "HttpGetScheduleInviteDetailTask.h"

HttpGetScheduleInviteDetailTask::HttpGetScheduleInviteDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETINVITEDETAIL;
}

HttpGetScheduleInviteDetailTask::~HttpGetScheduleInviteDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetScheduleInviteDetailTask::SetCallback(IRequestGetScheduleInviteDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetScheduleInviteDetailTask::SetParam(
                                          string inviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETINVITEDETAIL_INVITE_ID, inviteId.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteDetailTask::SetParam( "
            "task : %p, "
            "inviteId : %s"
            ")",
            this,
            inviteId.c_str()
            );
}

bool HttpGetScheduleInviteDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteDetailTask::ParseData( "
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
    HttpScheduleInviteDetailItem item;
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
        mpCallback->OnGetScheduleInviteDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

