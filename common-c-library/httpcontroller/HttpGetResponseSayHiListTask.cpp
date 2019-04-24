/*
 * HttpGetResponseSayHiListTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.6.Waiting for your reply列表
 */

#include "HttpGetResponseSayHiListTask.h"

HttpGetResponseSayHiListTask::HttpGetResponseSayHiListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_WAITINGREPLYSAYHILIST;

}

HttpGetResponseSayHiListTask::~HttpGetResponseSayHiListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetResponseSayHiListTask::SetCallback(IRequestGetResponseSayHiListCallback* callback) {
	mpCallback = callback;
}

void HttpGetResponseSayHiListTask::SetParam(
                                       LSSayHiListType type,
                                       int start,
                                       int step
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    snprintf(temp, sizeof(temp), "%d", GetLSSayHiListTypeWithInt(type));
    mHttpEntiy.AddContent(LIVEROOM_WAITINGREPLYSAYHILIST_SORT, temp);
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_WAITINGREPLYSAYHILIST_START, temp);

    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_WAITINGREPLYSAYHILIST_STEP, temp);


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetResponseSayHiListTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "start : %d, "
            "step : %d"
            ")",
            this,
            type,
            start,
            step
            );
}


bool HttpGetResponseSayHiListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetResponseSayHiListTask::ParseData( "
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
    HttpResponseSayHiListItem item;
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
        mpCallback->OnGetResponseSayHiList(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

