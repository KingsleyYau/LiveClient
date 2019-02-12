/*
 * HttpFindPasswordTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.16.找回密码
 */

#include "HttpFindPasswordTask.h"

HttpFindPasswordTask::HttpFindPasswordTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_FINDPW_PATH;
}

HttpFindPasswordTask::~HttpFindPasswordTask() {
	// TODO Auto-generated destructor stub
}

void HttpFindPasswordTask::SetCallback(IRequestFindPasswordCallback* callback) {
	mpCallback = callback;
}

void HttpFindPasswordTask::SetParam(
                                    const string sendMail,
                                    const string checkCode
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (sendMail.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_FINDPW_SENDMAIL, sendMail.c_str());
    }
    
    if (checkCode.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_FINDPW_VERIFYCODE, checkCode.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpFindPasswordTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpFindPasswordTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpFindPasswordTask::ParseData( "
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
        Json::Value root;
        Json::Reader reader;
        if (reader.parse(buf, root, false)) {
            if (root.isObject()) {
                if (root[COMMON_RESULT].isInt() && root[COMMON_RESULT].asInt() == 1) {
                    bParse = true;
                } else {
                    bParse = false;
                    if (root[COMMON_LIVE_NEW_CODE].isString()) {
                        errnum = root[COMMON_LIVE_NEW_CODE].asString();
                    }
                    if (root[LIVEROOM_FINDPW_ERRORMSG].isString()) {
                        errmsg = root[LIVEROOM_FINDPW_ERRORMSG].asString();
                    }
                }
            }
        }
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnFindPassword(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

