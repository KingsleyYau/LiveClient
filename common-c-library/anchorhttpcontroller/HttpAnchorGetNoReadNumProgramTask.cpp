/*
 * HttpAnchorGetNoReadNumProgramTask.cpp
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.2.获取节目未读数
 */

#include "HttpAnchorGetNoReadNumProgramTask.h"

HttpAnchorGetNoReadNumProgramTask::HttpAnchorGetNoReadNumProgramTask() {
	// TODO Auto-generated constructor stub
	mPath = ANCHORGETNOREADNUMPROGRAM_PATH;

}

HttpAnchorGetNoReadNumProgramTask::~HttpAnchorGetNoReadNumProgramTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetNoReadNumProgramTask::SetCallback(IRequestAnchorGetNoReadNumProgramCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetNoReadNumProgramTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetNoReadNumProgramTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpAnchorGetNoReadNumProgramTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetNoReadNumProgramTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetNoReadNumProgramTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    int num = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[ANCHORGETNOREADNUMPROGRAM_NUM].isNumeric()) {
                    num = dataJson[ANCHORGETNOREADNUMPROGRAM_NUM].asInt();
                }
            }
            
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorGetNoReadNumProgram(this, bParse, errnum, errmsg, num);
    }
    
    return bParse;
}

