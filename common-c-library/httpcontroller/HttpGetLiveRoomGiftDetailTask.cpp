/*
 *  HttpGetLiveRoomGiftDetailTask.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
 */

#include "HttpGetLiveRoomGiftDetailTask.h"

HttpGetLiveRoomGiftDetailTask::HttpGetLiveRoomGiftDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETGiftDetail;
    mToken = "";
    mGiftId = "";

}

HttpGetLiveRoomGiftDetailTask::~HttpGetLiveRoomGiftDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomGiftDetailTask::SetCallback(IRequestGetLiveRoomGiftDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomGiftDetailTask::SetParam(
                                             string token,
                                             string giftId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }

    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GiftID, giftId.c_str());
        mGiftId = giftId;
    }
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomGiftDetailTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "giftId : %s"
            ")",
            this,
            token.c_str(),
            giftId.c_str()
            );
}

const string& HttpGetLiveRoomGiftDetailTask::GetToken() {
    return mToken;
}

const string& HttpGetLiveRoomGiftDetailTask::GetGiftId() {
    return mGiftId;
}


bool HttpGetLiveRoomGiftDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomGiftDetailTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomGiftDetailTask::ParseData( buf : %s )", buf);
    }
    
    HttpLiveRoomGiftItem item;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson.isObject() ) {
                item.Parse(dataJson);
            }

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetLiveRoomGiftDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
