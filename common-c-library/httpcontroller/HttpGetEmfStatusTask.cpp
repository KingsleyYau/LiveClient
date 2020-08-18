/*
 * HttpGetEmfStatusTask.cpp
 *
 *  Created on: 2020-08-13
 *      Author: Alex
 *        desc: 13.10.获取EMF状态
 */

#include "HttpGetEmfStatusTask.h"

HttpGetEmfStatusTask::HttpGetEmfStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETEMFSTATUS;

}

HttpGetEmfStatusTask::~HttpGetEmfStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetEmfStatusTask::SetCallback(IRequestGetEmfStatusCallback* callback) {
	mpCallback = callback;
}

void HttpGetEmfStatusTask::SetParam(
                                  const string& emfId
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (emfId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETEMFSTATUS_EMF_ID, emfId.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfStatusTask::SetParam( "
            "task : %p, "
            "emfId : %s,"
            ")",
            this,
            emfId.c_str()
            );
}


bool HttpGetEmfStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfStatusTask::ParseData( "
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
    bool hasRead = false;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETEMFSTATUS_HAS_READ].isNumeric()) {
                    hasRead = (dataJson[LIVEROOM_GETEMFSTATUS_HAS_READ].asInt() == 0 ? false : true);
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
        mpCallback->OnGetEmfStatus(this, bParse, errnum, errmsg, hasRead);
    }
    
    return bParse;
}

