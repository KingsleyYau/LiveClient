/*
 * HttpGetManBaseInfoTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.14.获取个人信息（仅独立）
 */

#include "HttpGetManBaseInfoTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpGetManBaseInfoTask::HttpGetManBaseInfoTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_GETMANBASEINFO;
   
}

HttpGetManBaseInfoTask::~HttpGetManBaseInfoTask() {
    // TODO Auto-generated destructor stub
}

void HttpGetManBaseInfoTask::SetCallback(IRequestGetManBaseInfoCallback* callback) {
    mpCallback = callback;
}

void HttpGetManBaseInfoTask::SetParam(

                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetManBaseInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetManBaseInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetManBaseInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetManBaseInfoTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpManBaseInfoItem item;
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
            bParse = true;
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;

    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetManBaseInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
