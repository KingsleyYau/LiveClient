/*
 * HttpGetHangoutInvitStatusTask.cpp
 *
 *  Created on: 2018-4-13
 *      Author: Alex
 *        desc: 8.4.获取多人互动邀请状态
 */

#include "HttpGetHangoutInvitStatusTask.h"

HttpGetHangoutInvitStatusTask::HttpGetHangoutInvitStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETHANGOUTINVITSTATUS;
    mInviteId = "";

}

HttpGetHangoutInvitStatusTask::~HttpGetHangoutInvitStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetHangoutInvitStatusTask::SetCallback(IRequestGetHangoutInvitStatusCallback* callback) {
	mpCallback = callback;
}

void HttpGetHangoutInvitStatusTask::SetParam(
                                             const string& inviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( inviteId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETHANGOUTINVITSTATUS_INVITEID, inviteId.c_str());
        mInviteId = inviteId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutInvitStatusTask::SetParam( "
            "task : %p, "
            "inviteId : %s"
            ")",
            this,
            inviteId.c_str()
            );
}

bool HttpGetHangoutInvitStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutInvitStatusTask::ParseData( "
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
    HangoutInviteStatus status = HANGOUTINVITESTATUS_UNKNOW;
    string roomId = "";
    int expire = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_STATUS].isNumeric()) {
                status = GetIntToHangoutInviteStatus(dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_STATUS].asInt());
            }
            if (dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_ROOMID].isString()) {
                roomId = dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_ROOMID].asString();
            }
            if (dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_EXPIRE].isNumeric()) {
                expire = dataJson[LIVEROOM_GETHANGOUTINVITSTATUS_EXPIRE].asInt();
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetHangoutInvitStatus(this, bParse, errnum, errmsg, status, roomId, expire);
    }
    
    return bParse;
}

