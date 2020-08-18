/*
 * HttpGetActivityTimeTask.cpp
 *
 *  Created on: 2020-5-7
 *      Author: Alex
 *        desc: 17.11.获取服务器当前GMT时间戳
 */

#include "HttpGetActivityTimeTask.h"

HttpGetActivityTimeTask::HttpGetActivityTimeTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETACTIVITYTIME;
}

HttpGetActivityTimeTask::~HttpGetActivityTimeTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetActivityTimeTask::SetCallback(IRequestGetActivityTimeCallback* callback) {
	mpCallback = callback;
}

void HttpGetActivityTimeTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetActivityTimeTask::SetParam( "
            "task : %p"
            ")",
            this
            );
}

bool HttpGetActivityTimeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetActivityTimeTask::ParseData( "
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
    long long activityTime = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_SENDSCHEDULELIVEINVITE_TIME].isNumeric()) {
                    activityTime = dataJson[LIVEROOM_SENDSCHEDULELIVEINVITE_TIME].asLong();
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
        mpCallback->OnGetActivityTime(this, bParse, errnum, errmsg, activityTime);
    }
    
    return bParse;
}

