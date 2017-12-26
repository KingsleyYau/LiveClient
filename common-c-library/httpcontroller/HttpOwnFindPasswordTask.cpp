/*
 * HttpOwnFindPasswordTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.7.找回密码（仅独立）
 */

#include "HttpOwnFindPasswordTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpOwnFindPasswordTask::HttpOwnFindPasswordTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_FIND_PASSWORD_PATH;
    mSendMail = "";
    mCheckCode = "";
   
}

HttpOwnFindPasswordTask::~HttpOwnFindPasswordTask() {
    // TODO Auto-generated destructor stub
}

void HttpOwnFindPasswordTask::SetCallback(IRequestOwnFindPasswordCallback* callback) {
    mpCallback = callback;
}

void HttpOwnFindPasswordTask::SetParam(
                                     string sendMail,
                                     string checkCode
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( sendMail.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_FIND_PASSWORD_SENDMAIL, sendMail.c_str());
        mSendMail = sendMail;
    }
    if( checkCode.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_FIND_PASSWORD_CHECKCODE, checkCode.c_str());
        mCheckCode = checkCode;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnFindPasswordTask::SetParam( "
            "task : %p, "
            "sendMail : %s "
            "checkCode %s"
            ")",
            this,
            sendMail.c_str(),
            checkCode.c_str()
            );
}


bool HttpOwnFindPasswordTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnFindPasswordTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpOwnFindPasswordTask::ParseData( buf : %s )", buf);
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
        
        // LSalextest
        if (bParse == false) {
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
            bParse = true;
        }
        
    } else {
//        // 超时
//        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
//        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
        // LSalextest
        errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
        errmsg = "";
        bParse = true;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnOwnFindPassword(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
