/*
 * HttpLiveRoomCreateTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.1.新建直播间 
 */

#include "HttpLiveRoomCreateTask.h"

HttpLiveRoomCreateTask::HttpLiveRoomCreateTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CREATE;
    mToken = "";
    mRoomName = "";
    mRoomPhotoId = "";
    
    mRoomId = "";
    mRoomUrl = "";
}

HttpLiveRoomCreateTask::~HttpLiveRoomCreateTask() {
	// TODO Auto-generated destructor stub
}

void HttpLiveRoomCreateTask::SetCallback(IRequestLiveRoomCreateCallback* callback) {
	mpCallback = callback;
}

void HttpLiveRoomCreateTask::SetParam(
                                      string token,
                                      string roomNmae,
                                      string roomPhotoId
                                      ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( roomNmae.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_NAME, roomNmae.c_str());
        mRoomName = roomNmae;
    }
    
    if( roomPhotoId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PHOTOID, roomPhotoId.c_str());
        mRoomPhotoId = roomPhotoId;
    }


    FileLog("httpcontroller",
            "HttpLiveRoomCreateTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "roomNmae : %s, "
            "roomPhotoId : %s"
            ")",
            this,
            token.c_str(),
            roomNmae.c_str(),
            roomPhotoId.c_str()
            );
}

const string& HttpLiveRoomCreateTask::GetToken() {
    return mToken;
}

const string& HttpLiveRoomCreateTask::GetRoomName() {
    return mRoomName;
}

const string& HttpLiveRoomCreateTask::GetRoomPhotoId() {
    return mRoomPhotoId;
}

bool HttpLiveRoomCreateTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
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
        mpCallback->OnCreateLiveRoom(this, bParse, errnum, errmsg, mRoomId, mRoomUrl);
    }
    
    return bParse;
}
