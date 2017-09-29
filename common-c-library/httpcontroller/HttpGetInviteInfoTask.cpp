/*
 * HttpGetInviteInfoTask.cpp
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 3.9.获取指定立即私密邀请信息（已废弃）
 */

#include "HttpGetInviteInfoTask.h"

HttpGetInviteInfoTask::HttpGetInviteInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETINVITEINFO;
    mInvitationId = "";
}

HttpGetInviteInfoTask::~HttpGetInviteInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetInviteInfoTask::SetCallback(IRequestGetInviteInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetInviteInfoTask::SetParam(
                                     const string inviteId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( inviteId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_INVITE_INVITATIONID, inviteId.c_str());
        mInvitationId = inviteId;
    }
    
    FileLog("httpcontroller",
            "HttpGetInviteInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

/**
 *  邀请ID
 */
const string& HttpGetInviteInfoTask::GetInviteId() {
    return mInvitationId;
}


bool HttpGetInviteInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetInviteInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetInviteInfoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpInviteInfoItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetInviteInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

