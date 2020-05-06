/*
 * HttpGetScheduleInviteStatusTask.cpp
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.10.获取预付费直播邀请状态
 */

#include "HttpGetScheduleInviteStatusTask.h"

HttpGetScheduleInviteStatusTask::HttpGetScheduleInviteStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETINVITESTATUS;
}

HttpGetScheduleInviteStatusTask::~HttpGetScheduleInviteStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetScheduleInviteStatusTask::SetCallback(IRequestGetScheduleInviteStatusCallback* callback) {
	mpCallback = callback;
}

void HttpGetScheduleInviteStatusTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteStatusTask::SetParam( "
            "task : %p "
            ")",
            this
            );
}

bool HttpGetScheduleInviteStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteStatusTask::ParseData( "
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
    HttpScheduleInviteStatusItem item;
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
        mpCallback->OnGetScheduleInviteStatus(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

