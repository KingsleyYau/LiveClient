/*
 *  HttpGetLiveRoomAllGiftListTask.cpp
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
 */

#include "HttpGetLiveRoomAllGiftListTask.h"

HttpGetLiveRoomAllGiftListTask::HttpGetLiveRoomAllGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETALLGIFTLIST;
    mToken = "";

}

HttpGetLiveRoomAllGiftListTask::~HttpGetLiveRoomAllGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomAllGiftListTask::SetCallback(IRequestGetLiveRoomAllGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomAllGiftListTask::SetParam(
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
            "HttpGetLiveRoomAllGiftListTask::SetParam( "
            "task : %p, "
            "token : %s, "
            ")",
            this,
            token.c_str()
            );
}

const string& HttpGetLiveRoomAllGiftListTask::GetToken() {
    return mToken;
}


bool HttpGetLiveRoomAllGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomAllGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomAllGiftListTask::ParseData( buf : %s )", buf);
    }
    
    GiftItemList itemList;
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
                    HttpLiveRoomGiftItem item;
                    item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                    itemList.push_back(item);
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
        mpCallback->OnGetLiveRoomAllGiftList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
