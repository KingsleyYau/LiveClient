/*
 * HttpGetHangoutOnlineAnchorTask.cpp
 *
 *  Created on: 2019-1-18
 *      Author: Alex
 *        desc: 8.7.获取Hang-out在线主播列表
 */

#include "HttpGetHangoutOnlineAnchorTask.h"

HttpGetHangoutOnlineAnchorTask::HttpGetHangoutOnlineAnchorTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETRECENTCONTACEANCHOR;

}

HttpGetHangoutOnlineAnchorTask::~HttpGetHangoutOnlineAnchorTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetHangoutOnlineAnchorTask::SetCallback(IRequestGetHangoutOnlineAnchorCallback* callback) {
	mpCallback = callback;
}

void HttpGetHangoutOnlineAnchorTask::SetParam(
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutOnlineAnchorTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetHangoutOnlineAnchorTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutOnlineAnchorTask::ParseData( "
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
    HttpHangoutList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isArray()) {
                    for (int i = 0; i < dataJson.size(); i++) {
                        HttpHangoutListItem item;
                        item.Parse(dataJson.get(i, Json::Value::null));
                        list.push_back(item);
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
        mpCallback->OnGetHangoutOnlineAnchor(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

