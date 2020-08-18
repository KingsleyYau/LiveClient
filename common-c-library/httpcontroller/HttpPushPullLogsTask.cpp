/*
 * HttpPushPullLogsTask.cpp
 *
 *  Created on: 2020-05-14
 *      Author: Alex
 *        desc: 6.26.提交上报当前拉流的时间
 */

#include "HttpPushPullLogsTask.h"

HttpPushPullLogsTask::HttpPushPullLogsTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PUSHPULLLOGS;
    mLiveRoomId = "";
}

HttpPushPullLogsTask::~HttpPushPullLogsTask() {
	// TODO Auto-generated destructor stub
}

void HttpPushPullLogsTask::SetCallback(IRequestPushPullLogsCallback* callback) {
	mpCallback = callback;
}

void HttpPushPullLogsTask::SetParam(
                                   const string& liveRoomId
                                   ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( liveRoomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUSHPULLLOGS_LIVEROOMID, liveRoomId.c_str());
        mLiveRoomId = liveRoomId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPushPullLogsTask::SetParam( "
            "task : %p, "
            "liveRoomId : %s"
            ")",
            this,
            liveRoomId.c_str()
            );
}


bool HttpPushPullLogsTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPushPullLogsTask::ParseData( "
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
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnPushPullLogs(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

