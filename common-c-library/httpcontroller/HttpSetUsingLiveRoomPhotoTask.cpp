/*
 *  HttpSetUsingLiveRoomPhotoTask.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.12.设置默认使用封面图（用于主播设置默认的封面图）
 */

#include "HttpSetUsingLiveRoomPhotoTask.h"

HttpSetUsingLiveRoomPhotoTask::HttpSetUsingLiveRoomPhotoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SETUSINGROOMPHOTO;
    mToken = "";
    mPhotoId = "";

}

HttpSetUsingLiveRoomPhotoTask::~HttpSetUsingLiveRoomPhotoTask() {
	// TODO Auto-generated destructor stub
}

void HttpSetUsingLiveRoomPhotoTask::SetCallback(IRequestSetUsingLiveRoomPhotoCallback* callback) {
	mpCallback = callback;
}

void HttpSetUsingLiveRoomPhotoTask::SetParam(
                                        string token,
                                        string photoId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }
    if( photoId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PHOTOID, photoId.c_str());
        mPhotoId = photoId;
    }

    FileLog("httpcontroller",
            "HttpSetUsingLiveRoomPhotoTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "photoId :%s"
            ")",
            this,
            token.c_str(),
            photoId.c_str()
            );
}

const string& HttpSetUsingLiveRoomPhotoTask::GetToken() {
    return mToken;
}

const string& HttpSetUsingLiveRoomPhotoTask::GetPhotoId() {
    return mPhotoId;
}


bool HttpSetUsingLiveRoomPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpSetUsingLiveRoomPhotoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpSetUsingLiveRoomPhotoTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
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
        mpCallback->OnSetUsingLiveRoomPhoto(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
