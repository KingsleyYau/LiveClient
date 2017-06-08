/*
 * HttpCloseLiveRoomTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.3.关闭直播间
 */

#include "HttpCloseLiveRoomTask.h"

HttpCloseLiveRoomTask::HttpCloseLiveRoomTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CLOSE;
    mToken = "";
    mRoomId = "";
}

HttpCloseLiveRoomTask::~HttpCloseLiveRoomTask() {
	// TODO Auto-generated destructor stub
}

void HttpCloseLiveRoomTask::SetCallback(IRequestCloseLiveRoomCallback* callback) {
	mpCallback = callback;
}

void HttpCloseLiveRoomTask::SetParam(
                                     string token,
                                     string roomId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_ID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog("httpcontroller",
            "HttpCloseLiveRoomTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "roomId : %s, "
            ")",
            this,
            token.c_str(),
            roomId.c_str()
            );
}

const string& HttpCloseLiveRoomTask::GetToken() {
    return mToken;
}

const string& HttpCloseLiveRoomTask::GetRoomId() {
    return mRoomId;
}

bool HttpCloseLiveRoomTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpCloseLiveRoomTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpCloseLiveRoomTask::ParseData( buf : %s )", buf);
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
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnCloseLiveRoom(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
