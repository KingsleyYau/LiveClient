/*
 * HttpGetShowRoomInfoTask.cpp
 *
 *  Created on: 2018-4-23
 *      Author: Alex
 *        desc: 9.5.获取可进入的节目信息
 */

#include "HttpGetShowRoomInfoTask.h"

HttpGetShowRoomInfoTask::HttpGetShowRoomInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = GETSHOWROOMINFO_PATH;
    mLiveShowId = "";
}

HttpGetShowRoomInfoTask::~HttpGetShowRoomInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetShowRoomInfoTask::SetCallback(IRequestGetShowRoomInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetShowRoomInfoTask::SetParam(
                                               const string& liveShowId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (liveShowId.length() > 0) {
        mHttpEntiy.AddContent(GETSHOWROOMINFO_LIVESHOWID, liveShowId.c_str());
        mLiveShowId = liveShowId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetShowRoomInfoTask::SetParam( "
            "task : %p, "
            "liveShowId : %s ,"
            ")",
            this,
            liveShowId.c_str()
            );
}

bool HttpGetShowRoomInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetShowRoomInfoTask::ParseData( "
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
    HttpProgramInfoItem item;
    string roomId;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                if (dataJson[GETSHOWROOMINFO_SHOWINFO].isObject()) {
                    item.Parse(dataJson[GETSHOWROOMINFO_SHOWINFO]);
                }
                if (dataJson[GETSHOWROOMINFO_ROOMID].isString()) {
                    roomId = dataJson[GETSHOWROOMINFO_ROOMID].asString();
                }
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetShowRoomInfo(this, bParse, errnum, errmsg, item, roomId);
    }
    
    return bParse;
}

