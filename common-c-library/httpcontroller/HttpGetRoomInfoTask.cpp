/*
 * HttpGetRoomInfoTask.cpp
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 3.3.获取本人有效直播间或邀请信息(已废弃)
 */

#include "HttpGetRoomInfoTask.h"


HttpGetRoomInfoTask::HttpGetRoomInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CHECKROOM;
}

HttpGetRoomInfoTask::~HttpGetRoomInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetRoomInfoTask::SetCallback(IRequestGetRoomInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetRoomInfoTask::SetParam(

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetRoomInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpGetRoomInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetRoomInfoTask::ParseData( "
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
    HttpGetRoomInfoItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetRoomInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
