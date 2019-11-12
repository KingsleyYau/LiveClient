/*
 * HttpUpQnInviteIdTask.cpp
 *
 *  Created on: 2019-7-29
 *      Author: Alex
 *        desc: 6.23.qn邀请弹窗更新邀请id
 */

#include "HttpUpQnInviteIdTask.h"

HttpUpQnInviteIdTask::HttpUpQnInviteIdTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_UPONINVITEID;

}

HttpUpQnInviteIdTask::~HttpUpQnInviteIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpUpQnInviteIdTask::SetCallback(IRequestUpQnInviteIdCallback* callback) {
	mpCallback = callback;
}

void HttpUpQnInviteIdTask::SetParam(
                                    string manId,
                                    string anchorId,
                                    string inviteId,
                                    string roomId,
                                    LSBubblingInviteType inviteType
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (manId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_UPONINVITEID_MAN_ID, manId.c_str());
    }
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_UPONINVITEID_ANCHOR_ID, anchorId.c_str());
    }
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_UPONINVITEID_INVITE_ID, inviteId.c_str());
    }
    
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_UPONINVITEID_ROOM_ID, roomId.c_str());
    }
    
    if (inviteType > LSBUBBLINGINVITETYPE_BEGIN && inviteType <= LSBUBBLINGINVITETYPE_END) {
        snprintf(temp, sizeof(temp), "%d", inviteType );
        mHttpEntiy.AddContent(LIVEROOM_UPONINVITEID_INVITE_TYPE, temp);
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetContactListTask::SetParam( "
            "task : %p, "
            "manId : %s,"
            "anchorId : %s,"
            "inviteId : %s,"
            "roomId : %s,"
            "inviteType : %d"
            ")",
            this,
            manId.c_str(),
            anchorId.c_str(),
            inviteId.c_str(),
            roomId.c_str(),
            inviteType
            );
}


bool HttpUpQnInviteIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetContactListTask::ParseData( "
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
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnUpQnInviteId(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

