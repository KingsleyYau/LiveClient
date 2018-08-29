/*
 * HttpGetHangoutGiftListTask.cpp
 *
 *  Created on: 2018-5-8
 *      Author: Alex
 *        desc: 8.6.获取多人互动直播间可发送的礼物列表
 */

#include "HttpGetHangoutGiftListTask.h"

HttpGetHangoutGiftListTask::HttpGetHangoutGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_HANGOUTGIFTLIST;
    mRoomId = "";

}

HttpGetHangoutGiftListTask::~HttpGetHangoutGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetHangoutGiftListTask::SetCallback(IRequestGetHangoutGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetHangoutGiftListTask::SetParam(
                                             const string& roomId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_HANGOUTGIFTLIST_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutGiftListTask::SetParam( "
            "task : %p, "
            "roomId : %s"
            ")",
            this,
            roomId.c_str()
            );
}

bool HttpGetHangoutGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpHangoutGiftListItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetHangoutGiftList(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

