/*
 * HttpGetEmfDetailTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.4.获取信件详情
 */

#include "HttpGetEmfDetailTask.h"

HttpGetEmfDetailTask::HttpGetEmfDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_GETEMFDETAIL;

}

HttpGetEmfDetailTask::~HttpGetEmfDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetEmfDetailTask::SetCallback(IRequestGetEmfDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetEmfDetailTask::SetParam(
                                  string emfId
                                  ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if (emfId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_EMF_ID, emfId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfDetailTask::SetParam( "
            "task : %p, "
            "emfId : %s"
            ")",
            this,
            emfId.c_str()
            );
}


bool HttpGetEmfDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfDetailTask::ParseData( "
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
    HttpDetailEmfItem item;
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
        mpCallback->OnGetEmfDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

