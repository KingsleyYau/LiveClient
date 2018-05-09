/*
 * HttpAnchorGetShowRoomInfoTask.cpp
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.3.获取可进入的节目信息
 */

#include "HttpAnchorGetShowRoomInfoTask.h"

HttpAnchorGetShowRoomInfoTask::HttpAnchorGetShowRoomInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = ANCHORGETSHOWROOMINFO_PATH;
    mLiveShowId = "";
    
}

HttpAnchorGetShowRoomInfoTask::~HttpAnchorGetShowRoomInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetShowRoomInfoTask::SetCallback(IRequestAnchorGetShowRoomInfoCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetShowRoomInfoTask::SetParam(
                                                 const string& liveShowId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (liveShowId.length() > 0) {
        mHttpEntiy.AddContent(ANCHORGETSHOWROOMINFO_LIVESHOWID, liveShowId.c_str());
        mLiveShowId = liveShowId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetShowRoomInfoTask::SetParam( "
            "task : %p, "
            "liveShowId:%s"
            ")",
            this,
            liveShowId.c_str()
            );
}

bool HttpAnchorGetShowRoomInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetShowRoomInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetShowRoomInfoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    HttpAnchorProgramInfoItem liveShowInfo;
    string roomId = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                // 业务解析
                if (dataJson[ANCHORGETSHOWROOMINFO_SHOWINFO].isObject()) {
                    liveShowInfo.Parse(dataJson[ANCHORGETSHOWROOMINFO_SHOWINFO]);
                }
                if (dataJson[ANCHORGETSHOWROOMINFO_ROOMID].isString()) {
                    roomId = dataJson[ANCHORGETSHOWROOMINFO_ROOMID].asString();
                }
            }
           
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorGetShowRoomInfo(this, bParse, errnum, errmsg, liveShowInfo, roomId);
    }
    
    return bParse;
}

