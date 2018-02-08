/*
 * HttpCloseAdAnchorListTask.cpp
 *
 *  Created on: 2017-9-15
 *      Author: Alex
 *        desc: 6.5.关闭QN广告列表
 */

#include "HttpCloseAdAnchorListTask.h"

HttpCloseAdAnchorListTask::HttpCloseAdAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CLOSEADANCHORLIST;

}

HttpCloseAdAnchorListTask::~HttpCloseAdAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpCloseAdAnchorListTask::SetCallback(IRequestCloseAdAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpCloseAdAnchorListTask::SetParam(
                                          ) {


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCloseAdAnchorListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpCloseAdAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCloseAdAnchorListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpCloseAdAnchorListTask::ParseData( buf : %s )", buf);
    }
    
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnCloseAdAnchorList(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

