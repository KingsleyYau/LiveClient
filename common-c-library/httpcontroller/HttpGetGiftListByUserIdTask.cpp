/*
 *  HttpGetLiveRoomGiftListByUserIdTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）
 */

#include "HttpGetGiftListByUserIdTask.h"

HttpGetGiftListByUserIdTask::HttpGetGiftListByUserIdTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETGIFTLISTBYUSERID;
    mRoomId = "";

}

HttpGetGiftListByUserIdTask::~HttpGetGiftListByUserIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetGiftListByUserIdTask::SetCallback(IRequestGetGiftListByUserIdCallback* callback) {
	mpCallback = callback;
}

void HttpGetGiftListByUserIdTask::SetParam(
                                        string roomId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_ID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftListByUserIdTask::SetParam( "
            "task : %p, "
            "roomId : %s"
            ")",
            this,
            roomId.c_str()
            );
}


const string& HttpGetGiftListByUserIdTask::GetRoomId() {
    return mRoomId;
}


bool HttpGetGiftListByUserIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftListByUserIdTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetGiftListByUserIdTask::ParseData( buf : %s )", buf);
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
            
            if(dataJson.isObject()) {
                
                if( dataJson[COMMON_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpGiftWithIdItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
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
        mpCallback->OnGetGiftListByUserId(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
