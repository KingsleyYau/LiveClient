/*
 * HttpSetShareSucTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 6.12.分享链接成功
 */

#include "HttpSetShareSucTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpSetShareSucTask::HttpSetShareSucTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_SETSHARESUC;
    mShareId = "";
   
}

HttpSetShareSucTask::~HttpSetShareSucTask() {
    // TODO Auto-generated destructor stub
}

void HttpSetShareSucTask::SetCallback(IRequestSetShareSucCallback* callback) {
    mpCallback = callback;
}

void HttpSetShareSucTask::SetParam(
                                    string shareId
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( shareId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SETSHARESUC_SHAREID, shareId.c_str());
        mShareId = shareId;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetShareSucTask::SetParam( "
            "task : %p, "
            "shareId : %s "
            ")",
            this,
            shareId.c_str()
            );
}


bool HttpSetShareSucTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetShareSucTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSetShareSucTask      ::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;

    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;

    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSetShareSuc(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
