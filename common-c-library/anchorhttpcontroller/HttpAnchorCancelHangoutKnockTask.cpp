/*
 * HttpAnchorCancelHangoutKnockTask.cpp
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.7.取消敲门请求
 */

#include "HttpAnchorCancelHangoutKnockTask.h"

HttpAnchorCancelHangoutKnockTask::HttpAnchorCancelHangoutKnockTask() {
	// TODO Auto-generated constructor stub
	mPath = CANCELHANGOUTKNOCK_PATH;
    mKnockId = "";
}

HttpAnchorCancelHangoutKnockTask::~HttpAnchorCancelHangoutKnockTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorCancelHangoutKnockTask::SetCallback(IRequestAnchorCancelHangoutKnockCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorCancelHangoutKnockTask::SetParam(
                                                   const string& knockId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (knockId.length() > 0) {
        mHttpEntiy.AddContent(CANCELHANGOUTKNOCK_KNOCKID, knockId.c_str());
        mKnockId = knockId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorCancelHangoutKnockTask::SetParam( "
            "task : %p, "
            "knockId : %s ,"
            ")",
            this,
            knockId.c_str()
            );
}

bool HttpAnchorCancelHangoutKnockTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorCancelHangoutKnockTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorCancelHangoutKnockTask::ParseData( buf : %s )", buf);
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorCancelHangoutKnock(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

