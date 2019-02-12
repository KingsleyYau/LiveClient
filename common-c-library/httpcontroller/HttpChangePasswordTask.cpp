/*
 * HttpChangePasswordTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.17.修改密码
 */

#include "HttpChangePasswordTask.h"

HttpChangePasswordTask::HttpChangePasswordTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CHANGEPWD_PATH;
}

HttpChangePasswordTask::~HttpChangePasswordTask() {
	// TODO Auto-generated destructor stub
}

void HttpChangePasswordTask::SetCallback(IRequestChangePasswordCallback* callback) {
	mpCallback = callback;
}

void HttpChangePasswordTask::SetParam(
                                    const string passwordNew,
                                    const string passwordOld
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (passwordNew.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_FINDPW_PASSWORDNEW, passwordNew.c_str());
    }
    
    if (passwordOld.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_FINDPW_PASSWORDOLD, passwordOld.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangePasswordTask::SetParam( "
            "task : %p, "
            "passwordNew : %s, "
            "passwordOld : %s"
            ")",
            this,
            passwordNew.c_str(),
            passwordOld.c_str()
            );
}



bool HttpChangePasswordTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangePasswordTask::ParseData( "
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
        mpCallback->OnChangePassword(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

