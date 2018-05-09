/*
 * HttpAnchorHangoutGiftListTask.cpp
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 7.1.获取多人互动直播间礼物列表
 */

#include "HttpAnchorHangoutGiftListTask.h"

HttpAnchorHangoutGiftListTask::HttpAnchorHangoutGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = HANGOUTGIFTLIST_PATH;
    mRoomId = "";
}

HttpAnchorHangoutGiftListTask::~HttpAnchorHangoutGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorHangoutGiftListTask::SetCallback(IRequestAnchorHangoutGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorHangoutGiftListTask::SetParam(
                                                   const string& roomId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(HANGOUTGIFTLIST_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorHangoutGiftListTask::SetParam( "
            "task : %p, "
            "roomId : %s ,"
            ")",
            this,
            roomId.c_str()
            );
}

bool HttpAnchorHangoutGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorHangoutGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorHangoutGiftListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpAnchorHangoutGiftListItem hangoutGiftItem;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            // 业务解析
            hangoutGiftItem.Parse(dataJson);
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorHangoutGiftList(this, bParse, errnum, errmsg, hangoutGiftItem);
    }
    
    return bParse;
}

