/*
 *  HttpDelLiveRoomPhotoTast.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.13.删除开播封面图（用于主播删除开播封面图）
 */

#include "HttpDelLiveRoomPhotoTast.h"

HttpDelLiveRoomPhotoTast::HttpDelLiveRoomPhotoTast() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_DELROOMPHOTO;
    mToken = "";
    mPhotoId = "";

}

HttpDelLiveRoomPhotoTast::~HttpDelLiveRoomPhotoTast() {
	// TODO Auto-generated destructor stub
}

void HttpDelLiveRoomPhotoTast::SetCallback(IRequestDelLiveRoomPhotoCallback* callback) {
	mpCallback = callback;
}

void HttpDelLiveRoomPhotoTast::SetParam(
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
            "HttpDelLiveRoomPhotoTast::SetParam( "
            "task : %p, "
            "token : %s, "
            "photoId :%s"
            ")",
            this,
            token.c_str(),
            photoId.c_str()
            );
}

const string& HttpDelLiveRoomPhotoTast::GetToken() {
    return mToken;
}

const string& HttpDelLiveRoomPhotoTast::GetPhotoId() {
    return mPhotoId;
}


bool HttpDelLiveRoomPhotoTast::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpDelLiveRoomPhotoTast::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpDelLiveRoomPhotoTast::ParseData( buf : %s )", buf);
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
        mpCallback->OnDelLiveRoomPhoto(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
