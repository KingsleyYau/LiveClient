/*
 * ZBHttpCancelInstantInviteUserTask.cpp
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 4.8.主播取消已发的立即私密邀请
 */

#include "ZBHttpCancelInstantInviteUserTask.h"

ZBHttpCancelInstantInviteUserTask::ZBHttpCancelInstantInviteUserTask() {
	// TODO Auto-generated constructor stub
	mPath = CANCELINSTANTINVITEUSER_PATH;
    mInviteId = "";

}

ZBHttpCancelInstantInviteUserTask::~ZBHttpCancelInstantInviteUserTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpCancelInstantInviteUserTask::SetCallback(IRequestZBCancelInstantInviteUserCallback* callback) {
	mpCallback = callback;
}

void ZBHttpCancelInstantInviteUserTask::SetParam(
                                            const string& InviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (InviteId.length() >  0 ) {
        mHttpEntiy.AddContent(CANCELINSTANTINVITEUSER_INVITEID, InviteId.c_str());
        mInviteId = InviteId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpCancelInstantInviteUserTask::SetParam( "
            "task : %p, "
            "InviteId : %s ,"
            ")",
            this,
            InviteId.c_str()
            );
}

const string& ZBHttpCancelInstantInviteUserTask::GetInviteId() {
    return mInviteId;
}


bool ZBHttpCancelInstantInviteUserTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpCancelInstantInviteUserTask::ParseData( "
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
        mpCallback->OnZBCancelInstantInviteUser(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

