/*
 * ZBHttpRejectInstanceInviteTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.7.观众处理立即私密邀请
 */

#include "ZBHttpRejectInstanceInviteTask.h"

ZBHttpRejectInstanceInviteTask::ZBHttpRejectInstanceInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = REJECTINSTANCEINVITE_PATH;
    mInviteId = "";
    mRejectReason = "";

}

ZBHttpRejectInstanceInviteTask::~ZBHttpRejectInstanceInviteTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpRejectInstanceInviteTask::SetCallback(IRequestZBRejectInstanceInviteCallback* callback) {
	mpCallback = callback;
}

void ZBHttpRejectInstanceInviteTask::SetParam(
                                            const string& InviteId,
                                            const string& rejectReason
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (InviteId.length() >  0 ) {
        mHttpEntiy.AddContent(REJECTINSTANCEINVITE_INVITEID, InviteId.c_str());
        mInviteId = InviteId;
    }

    if (rejectReason.length() >  0 ) {
        mHttpEntiy.AddContent(REJECTINSTANCEINVITE_REJECTREASON, rejectReason.c_str());
        mRejectReason = rejectReason;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpRejectInstanceInviteTask::SetParam( "
            "task : %p, "
            "InviteId : %s"
            "rejectReason : %s"
            ")",
            this,
            InviteId.c_str(),
            rejectReason.c_str()
            );
}

const string& ZBHttpRejectInstanceInviteTask::GetInviteId() {
    return mInviteId;
}

const string& ZBHttpRejectInstanceInviteTask::GetRejectReason() {
    return mRejectReason;
}

bool ZBHttpRejectInstanceInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpRejectInstanceInviteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpRejectInstanceInviteTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnZBRejectInstanceInvite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

