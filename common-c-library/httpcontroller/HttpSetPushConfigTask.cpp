/*
 * HttpSetPushConfigTask.cpp
 *
 *  Created on: 2018-9-28
 *      Author: Alex
 *        desc: 11.2.修改推送设置
 */

#include "HttpSetPushConfigTask.h"

HttpSetPushConfigTask::HttpSetPushConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = SETPUSHCONFIG_PATH;
}

HttpSetPushConfigTask::~HttpSetPushConfigTask() {
	// TODO Auto-generated destructor stub
}

void HttpSetPushConfigTask::SetCallback(IRequestSetPushConfigCallback* callback) {
	mpCallback = callback;
}

void HttpSetPushConfigTask::SetParam(
                                     bool isPriMsgAppPush,
                                     bool isMailAppPush
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    mHttpEntiy.SetConnectTimeout(8);
    
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", isPriMsgAppPush == true ? 1 : 0);
    mHttpEntiy.AddContent(SETPUSHCONFIG_PRIVMSG_PUSH, temp);
    
    snprintf(temp, sizeof(temp), "%d", isMailAppPush == true ? 1 : 0);
    mHttpEntiy.AddContent(SETPUSHCONFIG_MAIL_PUSH, temp);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetPushConfigTask::SetParam( "
            "task : %p, "
            "isPriMsgAppPush : %d"
            "isMailAppPush : %d"
            ")",
            this,
            isPriMsgAppPush,
            isMailAppPush
            );
}

bool HttpSetPushConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetPushConfigTask::ParseData( "
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
        mpCallback->OnSetPushConfig(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

