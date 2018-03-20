/*
 * ZBHttpAcceptScheduledInviteTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.2.主播接受预约邀请
 */

#include "ZBHttpAcceptScheduledInviteTask.h"

ZBHttpAcceptScheduledInviteTask::ZBHttpAcceptScheduledInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = ACCEPTSCHEDULEDINVITE_PATH;
    mInviteId = "";
}

ZBHttpAcceptScheduledInviteTask::~ZBHttpAcceptScheduledInviteTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpAcceptScheduledInviteTask::SetCallback(IRequestZBAcceptScheduledInviteCallback* callback) {
	mpCallback = callback;
}


void ZBHttpAcceptScheduledInviteTask::SetParam(
                                     string inviteId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(ACCEPTSCHEDULEDINVITE_INVITEID, inviteId.c_str());
        mInviteId = inviteId;
    }

    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpAcceptScheduledInviteTask::SetParam( "
            "task : %p, "
            "inviteId :%s, "
            ")",
            this,
            inviteId.c_str()
            );
}


string ZBHttpAcceptScheduledInviteTask::GetInviteId() {
    return mInviteId;
}


bool ZBHttpAcceptScheduledInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpAcceptScheduledInviteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpAcceptScheduledInviteTask::ParseData( buf : %s )", buf);
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBAcceptScheduledInvite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

