/*
 * HttpGetVoucherAvailableInfoTask.cpp
 *
 *  Created on: 2017-1-24
 *      Author: Alex
 *        desc: 5.6.获取试用券可用信息
 */

#include "HttpGetVoucherAvailableInfoTask.h"

HttpGetVoucherAvailableInfoTask::HttpGetVoucherAvailableInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETVOUCHERAVAILABLEINFO;
}

HttpGetVoucherAvailableInfoTask::~HttpGetVoucherAvailableInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetVoucherAvailableInfoTask::SetCallback(IRequestGetVoucherAvailableInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetVoucherAvailableInfoTask::SetParam(
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetVoucherAvailableInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetVoucherAvailableInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetVoucherAvailableInfoTask::ParseData( "
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
    HttpVoucherInfoItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetVoucherAvailableInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

