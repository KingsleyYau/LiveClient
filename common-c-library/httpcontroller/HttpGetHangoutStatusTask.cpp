/*
 * HttpGetHangoutStatusTask.cpp
 *
 *  Created on: 2019-1-23
 *      Author: Alex
 *        desc: 8.11.获取当前会员Hangout直播状态
 */

#include "HttpGetHangoutStatusTask.h"

HttpGetHangoutStatusTask::HttpGetHangoutStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETHANGOUTATUS;

}

HttpGetHangoutStatusTask::~HttpGetHangoutStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetHangoutStatusTask::SetCallback(IRequestGetHangoutStatusCallback* callback) {
	mpCallback = callback;
}

void HttpGetHangoutStatusTask::SetParam(
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutStatusTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetHangoutStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutStatusTask::ParseData( "
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
    HttpHangoutStatusList list;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson);
        if (dataJson.isArray()) {
            for (int i = 0; i < dataJson.size(); i++) {
                HttpHangoutStatusItem item;
                item.Parse(dataJson.get(i, Json::Value::null));
                list.push_back(item);
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetHangoutStatus(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

