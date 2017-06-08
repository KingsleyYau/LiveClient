/*
 * HttpGetLiveRoomUserPhotoTask.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 4.1.获取用户头像
 */

#include "HttpGetLiveRoomUserPhotoTask.h"


HttpGetLiveRoomUserPhotoTask::HttpGetLiveRoomUserPhotoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PERSONAL_USERPHOTO;
    mToken = "";
    mUserId = "";
    mPhotoType = PHOTOTYPE_UNKNOWN;
    mPhotoUrl = "";
}

HttpGetLiveRoomUserPhotoTask::~HttpGetLiveRoomUserPhotoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomUserPhotoTask::SetCallback(IRequestGetLiveRoomUserPhotoCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomUserPhotoTask::SetParam(
                                            string token,
                                            string userid,
                                            PhotoType phototype
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( userid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PERSONAL_USERID, userid.c_str());
        mUserId = userid;
    }

    char temp[16];
    snprintf(temp, sizeof(temp), "%d", phototype);
    mHttpEntiy.AddContent(LIVEROOM_PERSONAL_PHOTOTYPE, temp);
    mPhotoType = phototype;
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomUserPhotoTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "userid : %s, "
            "phototype : %d, "
            ")",
            this,
            token.c_str(),
            userid.c_str(),
            phototype
            );
}

const string& HttpGetLiveRoomUserPhotoTask::GetToken() {
    return mToken;
}

const string& HttpGetLiveRoomUserPhotoTask::GetUserId() {
    return mUserId;
}

PhotoType HttpGetLiveRoomUserPhotoTask::GetPhotoType() {
    return mPhotoType;
}

const string& HttpGetLiveRoomUserPhotoTask::GetPhotoUrl() {
    return mPhotoUrl;
}

bool HttpGetLiveRoomUserPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomUserPhotoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomUserPhotoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if( dataJson.isObject() ) {
                if (dataJson[LIVEROOM_PUBLIC_PERSONAL_PHOTOURL].isString()) {
                    mPhotoUrl = dataJson[LIVEROOM_PUBLIC_PERSONAL_PHOTOURL].asString();
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
        mpCallback->OnGetLiveRoomUserPhoto(this, bParse, errnum, errmsg, mPhotoUrl);
    }
    
    return bParse;
}
