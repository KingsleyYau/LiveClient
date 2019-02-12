/*
 * HttpDestroyTokenTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.15.销毁App token
 */

#include "HttpDestroyTokenTask.h"

HttpDestroyTokenTask::HttpDestroyTokenTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_DESTROYTOKEN_PATH;


}

HttpDestroyTokenTask::~HttpDestroyTokenTask() {
	// TODO Auto-generated destructor stub
}

void HttpDestroyTokenTask::SetCallback(IRequestDestroyTokenCallback* callback) {
	mpCallback = callback;
}

void HttpDestroyTokenTask::SetParam(

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDestroyTokenTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpDestroyTokenTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDestroyTokenTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnDestroyToken(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

