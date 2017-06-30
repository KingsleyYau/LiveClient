/*
 *  HttpGetLiveRoomGiftListByUserIdTask.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）
 */

#include "HttpGetLiveRoomGiftListByUserIdTask.h"

HttpGetLiveRoomGiftListByUserIdTask::HttpGetLiveRoomGiftListByUserIdTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETGIFTLISTBYUSERID;
    mToken = "";
    mRoomId = "";

}

HttpGetLiveRoomGiftListByUserIdTask::~HttpGetLiveRoomGiftListByUserIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomGiftListByUserIdTask::SetCallback(IRequestGetLiveRoomGiftListByUserIdCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomGiftListByUserIdTask::SetParam(
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
            "HttpGetLiveRoomGiftListByUserIdTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "roomId : %s"
            ")",
            this,
            token.c_str(),
            roomId.c_str()
            );
}

const string& HttpGetLiveRoomGiftListByUserIdTask::GetToken() {
    return mToken;
}

const string& HttpGetLiveRoomGiftListByUserIdTask::GetRoomId() {
    return mRoomId;
}


bool HttpGetLiveRoomGiftListByUserIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomGiftListByUserIdTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomGiftListByUserIdTask::ParseData( buf : %s )", buf);
    }
    
    GiftWithIdItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson[COMMON_LIST].isArray() ) {
                int i = 0;
                for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                    string item = "";
                    Json::Value itemJson;
                    itemJson = dataJson[COMMON_LIST].get(i, Json::Value::null);
                    if (itemJson.isObject()) {
                        if (itemJson[LIVEROOM_PUBLIC_GIFTID].isString()) {
                            item = itemJson[LIVEROOM_PUBLIC_GIFTID].asString();
                            itemList.push_back(item);
                        }
                    }
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
        mpCallback->OnGetLiveRoomGiftListByUserId(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
