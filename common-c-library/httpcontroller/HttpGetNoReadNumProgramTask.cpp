/*
 * HttpGetNoReadNumProgramTask.cpp
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.1.获取节目列表未读
 */

#include "HttpGetNoReadNumProgramTask.h"

HttpGetNoReadNumProgramTask::HttpGetNoReadNumProgramTask() {
	// TODO Auto-generated constructor stub
	mPath = GETNOREADNUMPROGRAM_PATH;

}

HttpGetNoReadNumProgramTask::~HttpGetNoReadNumProgramTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetNoReadNumProgramTask::SetCallback(IRequestGetNoReadNumProgramCallback* callback) {
	mpCallback = callback;
}

void HttpGetNoReadNumProgramTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetNoReadNumProgramTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetNoReadNumProgramTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetNoReadNumProgramTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetNoReadNumProgramTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    int num = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[GETNOREADNUMPROGRAM_NUM].isNumeric()) {
                num = dataJson[GETNOREADNUMPROGRAM_NUM].asInt();
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetNoReadNumProgram(this, bParse, errnum, errmsg, num);
    }
    
    return bParse;
}

