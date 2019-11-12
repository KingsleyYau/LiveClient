/*
 * HttpGetCurrentRoomInfoTask.cpp
 *
 *  Created on: 2019-11-07
 *      Author: Alex
 *        desc: 3.9.获取主播当前直播间信息
 */

#include "HttpGetCurrentRoomInfoTask.h"

HttpGetCurrentRoomInfoTask::HttpGetCurrentRoomInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = GETCURRENTROOMINFO_PATH;
}

HttpGetCurrentRoomInfoTask::~HttpGetCurrentRoomInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCurrentRoomInfoTask::SetCallback(IRequestGetCurrentRoomInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetCurrentRoomInfoTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCurrentRoomInfoTask::SetParam( "
            "task : %p "
            ")",
            this
            );
}

bool HttpGetCurrentRoomInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCurrentRoomInfoTask::ParseData( "
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
    ZBHttpCurrentRoomItem roomItem;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            roomItem.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetCurrentRoomInfo(this, bParse, errnum, errmsg, roomItem);
    }
    
    return bParse;
}

