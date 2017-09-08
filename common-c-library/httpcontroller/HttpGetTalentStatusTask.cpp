/*
 * HttpGetTalentStatusTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 3.11.获取才艺点播邀请状态
 */

#include "HttpGetTalentStatusTask.h"

HttpGetTalentStatusTask::HttpGetTalentStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETTALENTSTATUS;
    mRoomId = "";
    mTalentInviteId = "";
}

HttpGetTalentStatusTask::~HttpGetTalentStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetTalentStatusTask::SetCallback(IRequestGetTalentStatusCallback* callback) {
	mpCallback = callback;
}

void HttpGetTalentStatusTask::SetParam(
                                     const string roomId,
                                       const string talentInviteId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETTALENTSTATUS_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    if( talentInviteId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETTALENTSTATUS_TALENTINVITEID, talentInviteId.c_str());
        mTalentInviteId = talentInviteId;
    }
    
    FileLog("httpcontroller",
            "HttpGetTalentStatusTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

/**
 *  邀请ID
 */
const string& HttpGetTalentStatusTask::GetRoomId() {
    return mRoomId;
}

/*
 * 才艺点播邀请ID
 */
const string& HttpGetTalentStatusTask::TalentInviteId() {
    return mTalentInviteId;
}

bool HttpGetTalentStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetTalentStatusTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetTalentStatusTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
   HttpGetTalentStatusItem item;
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
        mpCallback->OnGetTalentStatus(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

