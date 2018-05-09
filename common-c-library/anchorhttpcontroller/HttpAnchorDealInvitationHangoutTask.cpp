/*
 * HttpAnchorDealInvitationHangoutTask.cpp
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.3.主播回复多人互动邀请
 */

#include "HttpAnchorDealInvitationHangoutTask.h"

HttpAnchorDealInvitationHangoutTask::HttpAnchorDealInvitationHangoutTask() {
	// TODO Auto-generated constructor stub
	mPath = DEALINVITATIONHANGOUT_PATH;
    mInviteId = "";
    mType = ANCHORMULTIPLAYERREPLYTYPE_AGREE;
}

HttpAnchorDealInvitationHangoutTask::~HttpAnchorDealInvitationHangoutTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorDealInvitationHangoutTask::SetCallback(IRequestAnchorDealInvitationHangoutCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorDealInvitationHangoutTask::SetParam(
                                                   const string& inviteId,
                                                   AnchorMultiplayerReplyType type
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(DEALINVITATIONHANGOUT_INVITEID, inviteId.c_str());
        mInviteId = inviteId;
    }
    
    char temp[16];
    if (type >= ANCHORMULTIPLAYERREPLYTYPE_AGREE && type <= ANCHORMULTIPLAYERREPLYTYPE_REJECT) {
        snprintf(temp, sizeof(temp), "%d", type);
        mHttpEntiy.AddContent(DEALINVITATIONHANGOUT_TYPE, temp);
        mType = type;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorDealInvitationHangoutTask::SetParam( "
            "task : %p, "
            "inviteId : %s ,"
            "type : %d"
            ")",
            this,
            inviteId.c_str(),
            type
            );
}

bool HttpAnchorDealInvitationHangoutTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorDealInvitationHangoutTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorDealInvitationHangoutTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string roomId = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[DEALINVITATIONHANGOUT_ROOMID].isString()) {
                    roomId = dataJson[DEALINVITATIONHANGOUT_ROOMID].asString();
                }
                
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorDealInvitationHangout(this, bParse, errnum, errmsg, roomId);
    }
    
    return bParse;
}

