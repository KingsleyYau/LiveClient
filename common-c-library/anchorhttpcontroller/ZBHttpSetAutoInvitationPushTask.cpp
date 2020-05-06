/*
 * ZBHttpSetAutoInvitationPushTask.cpp
 *
 *  Created on: 2019-11-22
 *      Author: Alex
 *        desc: 3.10.设置主播公开直播间自动邀请状态
 */

#include "ZBHttpSetAutoInvitationPushTask.h"

ZBHttpSetAutoInvitationPushTask::ZBHttpSetAutoInvitationPushTask() {
	// TODO Auto-generated constructor stub
	mPath = SETAUTOINVITATIONPUBLIC_PATH;
    mStatus = ZBSETPUSHTYPE_CLOSE;

}

ZBHttpSetAutoInvitationPushTask::~ZBHttpSetAutoInvitationPushTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpSetAutoInvitationPushTask::SetCallback(IRequestZBSetAutoInvitationPushCallback* callback) {
	mpCallback = callback;
}

void ZBHttpSetAutoInvitationPushTask::SetParam(
                                            ZBSetPushType status
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", status);
    mHttpEntiy.AddContent(SETAUTOINVITATIONPUBLIC_STATUS, temp);
    mStatus = status;

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetAutoInvitationPushTask::SetParam( "
            "task : %p, "
            "status : %d ,"
            ")",
            this,
            status
            );
}


bool ZBHttpSetAutoInvitationPushTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetAutoInvitationPushTask::ParseData( "
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
        mpCallback->OnZBSetAutoInvitationPush(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

