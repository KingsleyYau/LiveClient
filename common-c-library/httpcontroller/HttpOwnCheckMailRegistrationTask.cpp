/*
 * HttpOwnCheckMailRegistrationTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.8.检测邮箱注册状态（仅独立）
 */

#include "HttpOwnCheckMailRegistrationTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpOwnCheckMailRegistrationTask::HttpOwnCheckMailRegistrationTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_CHECK_MAIL_PATH;
    mEmail = "";
   
}

HttpOwnCheckMailRegistrationTask::~HttpOwnCheckMailRegistrationTask() {
    // TODO Auto-generated destructor stub
}

void HttpOwnCheckMailRegistrationTask::SetCallback(IRequestOwnCheckMailRegistrationCallback* callback) {
    mpCallback = callback;
}

void HttpOwnCheckMailRegistrationTask::SetParam(
                                     string email
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( email.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_CHECK_MAIL_EMAIL, email.c_str());
        mEmail = email;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnCheckMailRegistrationTask::SetParam( "
            "task : %p, "
            "email : %s "
            ")",
            this,
            email.c_str()
            );
}


bool HttpOwnCheckMailRegistrationTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnCheckMailRegistrationTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpOwnCheckMailRegistrationTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnOwnCheckMailRegistration(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
