/*
 * HttpGetAllSayHiListTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.5.发送sayHi
 */

#include "HttpGetAllSayHiListTask.h"

HttpGetAllSayHiListTask::HttpGetAllSayHiListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ALLSAYHILIST;

}

HttpGetAllSayHiListTask::~HttpGetAllSayHiListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAllSayHiListTask::SetCallback(IRequestGetAllSayHiListCallback* callback) {
	mpCallback = callback;
}

void HttpGetAllSayHiListTask::SetParam(
                                       int start,
                                       int step
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_ALLSAYHILIST_START, temp);

    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_ALLSAYHILIST_STEP, temp);


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAllSayHiListTask::SetParam( "
            "task : %p, "
            "start : %d, "
            "step : %d"
            ")",
            this,
            start,
            step
            );
}


bool HttpGetAllSayHiListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAllSayHiListTask::ParseData( "
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
    HttpAllSayHiListItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
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
        mpCallback->OnGetAllSayHiList(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

