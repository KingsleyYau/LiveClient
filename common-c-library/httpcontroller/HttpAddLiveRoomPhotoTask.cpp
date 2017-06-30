/*
 *  HttpAddLiveRoomPhotoTask.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.11.添加开播封面图（用于主播添加开播封面图）
 */

#include "HttpAddLiveRoomPhotoTask.h"

HttpAddLiveRoomPhotoTask::HttpAddLiveRoomPhotoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ADDROOMPHOTO;
    mToken = "";
    mPhotoId = "";

}

HttpAddLiveRoomPhotoTask::~HttpAddLiveRoomPhotoTask() {
	// TODO Auto-generated destructor stub
}

void HttpAddLiveRoomPhotoTask::SetCallback(IRequestAddLiveRoomPhotoCallback* callback) {
	mpCallback = callback;
}

void HttpAddLiveRoomPhotoTask::SetParam(
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
            "HttpAddLiveRoomPhotoTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "photoId :%s"
            ")",
            this,
            token.c_str(),
            photoId.c_str()
            );
}

const string& HttpAddLiveRoomPhotoTask::GetToken() {
    return mToken;
}

const string& HttpAddLiveRoomPhotoTask::GetPhotoId() {
    return mPhotoId;
}


bool HttpAddLiveRoomPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpAddLiveRoomPhotoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpAddLiveRoomPhotoTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnAddLiveRoomPhoto(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
