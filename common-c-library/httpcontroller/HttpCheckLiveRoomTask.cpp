/*
 * HttpCheckLiveRoomTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.2.获取本人正在直播的直播间信息
 */

#include "HttpCheckLiveRoomTask.h"

HttpCheckLiveRoomTask::HttpCheckLiveRoomTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CHECK;
    mToken = "";
    mRoomId = "";
    mRoomUrl = "";
}

HttpCheckLiveRoomTask::~HttpCheckLiveRoomTask() {
	// TODO Auto-generated destructor stub
}

void HttpCheckLiveRoomTask::SetCallback(IRequestCheckLiveRoomCallback* callback) {
	mpCallback = callback;
}

void HttpCheckLiveRoomTask::SetParam(
                                     string token
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }

    FileLog("httpcontroller",
            "HttpLiveRoomCreateTask::SetParam( "
            "task : %p, "
            "token : %s, "
            ")",
            this,
            token.c_str()
            );
}

const string& HttpCheckLiveRoomTask::GetToken() {
    return mToken;
}

bool HttpCheckLiveRoomTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpLiveRoomCreateTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpLiveRoomCreateTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson.isObject() ) {
                if (dataJson[LIVEROOM_PUBLIC_ID].isString()) {
                    mRoomId = dataJson[LIVEROOM_PUBLIC_ID].asString();
                }
                if (dataJson[LIVEROOM_PUBLIC_URL].isString()) {
                    mRoomUrl = dataJson[LIVEROOM_PUBLIC_URL].asString();
                }
            }

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnCheckLiveRoom(this, bParse, errnum, errmsg, mRoomId, mRoomUrl);
    }
    
    return bParse;
}
