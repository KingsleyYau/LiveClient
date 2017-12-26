/*
 * HttpSetFavoriteTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 6.3.添加／取消收藏
 */

#include "HttpSetFavoriteTask.h"

HttpSetFavoriteTask::HttpSetFavoriteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SETFAVORITE;
    mUserId = "";
    mIsFav = false;
}

HttpSetFavoriteTask::~HttpSetFavoriteTask() {
	// TODO Auto-generated destructor stub
}

void HttpSetFavoriteTask::SetCallback(IRequestSetFavoriteCallback* callback) {
	mpCallback = callback;
}

void HttpSetFavoriteTask::SetParam(
                                   const string& userId,
                                   const string& roomId,
                                   bool isFav
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( userId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SETFAVORITE_USERID, userId.c_str());
        mUserId = userId;
    }
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_SETFAVORITE_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", isFav ? 1 : 0);
    mHttpEntiy.AddContent(LIVEROOM_SETFAVORITE_ISFAV, temp);
    mIsFav = isFav;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetFavoriteTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpSetFavoriteTask::GetUserId() {
    return mUserId;
}

const string& HttpSetFavoriteTask::GetRoomId() {
    return mRoomId;
}

bool HttpSetFavoriteTask::GetIsFav() {
    return mIsFav;
}

bool HttpSetFavoriteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetFavoriteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSetFavoriteTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnSetFavorite(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

