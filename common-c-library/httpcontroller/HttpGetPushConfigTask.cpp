/*
 * HttpGetPushConfigTask.cpp
 *
 *  Created on: 2018-9-28
 *      Author: Alex
 *        desc: 11.1.获取推送设置
 */

#include "HttpGetPushConfigTask.h"

HttpGetPushConfigTask::HttpGetPushConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = GETPUSHCONFIG_PATH;
}

HttpGetPushConfigTask::~HttpGetPushConfigTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPushConfigTask::SetCallback(IRequestGetPushConfigCallback* callback) {
	mpCallback = callback;
}

void HttpGetPushConfigTask::SetParam(
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
                                          
    mHttpEntiy.SetConnectTimeout(8);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPushConfigTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetPushConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPushConfigTask::ParseData( "
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
    bool isPriMsgAppPush = false;
    bool isMailAppPush = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[GETPUSHCONFIG_PRIVMSG_PUSH].isNumeric()) {
                    isPriMsgAppPush = dataJson[GETPUSHCONFIG_PRIVMSG_PUSH].asInt() == 0 ? false : true;
                }
                if (dataJson[GETPUSHCONFIG_MAIL_PUSH].isNumeric()) {
                    isMailAppPush = dataJson[GETPUSHCONFIG_MAIL_PUSH].asInt() == 0 ? false : true;
                }
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetPushConfig(this, bParse, errnum, errmsg, isPriMsgAppPush, isMailAppPush);
    }
    
    return bParse;
}

