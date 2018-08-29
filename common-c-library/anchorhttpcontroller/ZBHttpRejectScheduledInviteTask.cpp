/*
 * ZBHttpRejectScheduledInviteTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)
 */

#include "ZBHttpRejectScheduledInviteTask.h"

ZBHttpRejectScheduledInviteTask::ZBHttpRejectScheduledInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = REJECTSCHEDULEDULEDINVITE_PATH;
    mInvitationId = "";
}

ZBHttpRejectScheduledInviteTask::~ZBHttpRejectScheduledInviteTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpRejectScheduledInviteTask::SetCallback(IRequestZBRejectScheduledInviteCallback* callback) {
	mpCallback = callback;
}


void ZBHttpRejectScheduledInviteTask::SetParam(
                                            string invitationId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (invitationId.length() > 0) {
        mHttpEntiy.AddContent(REJECTSCHEDULEDULEDINVITE_INVITEID, invitationId.c_str());
        mInvitationId = invitationId;
    }
 
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpRejectScheduledInviteTask::SetParam( "
            "task : %p, "
            "invitationId :%s, "
            ")",
            this,
            invitationId.c_str()
            );
}


string ZBHttpRejectScheduledInviteTask::GetInvitationId() {
    return mInvitationId;
}


bool ZBHttpRejectScheduledInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpRejectScheduledInviteTask::ParseData( "
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
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBRejectScheduledInvite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

