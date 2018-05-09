/*
 * HttpSendInvitationHangoutTask.cpp
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *        desc: 8.2.发起多人互动邀请
 */

#include "HttpSendInvitationHangoutTask.h"

HttpSendInvitationHangoutTask::HttpSendInvitationHangoutTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDINVITATIONHANGOUT;
    mRoomId = "";
    mAnchorId = "";
    mRecommendId = "";
}

HttpSendInvitationHangoutTask::~HttpSendInvitationHangoutTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendInvitationHangoutTask::SetCallback(IRequestSendInvitationHangoutCallback* callback) {
	mpCallback = callback;
}

void HttpSendInvitationHangoutTask::SetParam(
                                             const string& roomId,
                                             const string& anchorId,
                                             const string& recommendId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDINVITATIONHANGOUT_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    if( anchorId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDINVITATIONHANGOUT_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }
    
    if( recommendId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDINVITATIONHANGOUT_RECOMMENDID, recommendId.c_str());
        mRecommendId = recommendId;
    }
    


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendInvitationHangoutTask::SetParam( "
            "task : %p, "
            "roomId : %s,"
            "anchorId : %s,"
            "recommendId : %s"
            ")",
            this,
            roomId.c_str(),
            anchorId.c_str(),
            recommendId.c_str()
            );
}

bool HttpSendInvitationHangoutTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendInvitationHangoutTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSendInvitationHangoutTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string  roomId = "";
    string  inviteId = "";
    int expire = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_SENDINVITATIONHANGOUT_ROOMID].isString()) {
                    roomId = dataJson[LIVEROOM_SENDINVITATIONHANGOUT_ROOMID].asString();
                }
                if (dataJson[LIVEROOM_SENDINVITATIONHANGOUT_INVITEID].isString()) {
                    inviteId = dataJson[LIVEROOM_SENDINVITATIONHANGOUT_INVITEID].asString();
                }
                if (dataJson[LIVEROOM_SENDINVITATIONHANGOUT_EXPIRE].isNumeric()) {
                    expire = dataJson[LIVEROOM_SENDINVITATIONHANGOUT_EXPIRE].isInt();
                }
            }

        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSendInvitationHangout(this, bParse, errnum, errmsg, roomId, inviteId, expire);
    }
    
    return bParse;
}

