/*
 * HttpDoLoginTask.cpp
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 10.4.标记私信已读
 */

#include "HttpDoLoginTask.h"

HttpDoLoginTask::HttpDoLoginTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_DOLOGIN_PATH;

}

HttpDoLoginTask::~HttpDoLoginTask() {
	// TODO Auto-generated destructor stub
}

void HttpDoLoginTask::SetCallback(IRequestDoLoginCallback* callback) {
	mpCallback = callback;
}

void HttpDoLoginTask::SetParam(
                                   const string& token,
                                   const string& memberId,
                                   const string& deviceId,
                                   const string& versionCode,
                                   const string& model,
                                   const string& manufacturer
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (token.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_TOKEN, token.c_str());

    }
    
    if (memberId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_MEMBERID, memberId.c_str());
    }
    
    if (deviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_DEVICEID, deviceId.c_str());
    }
    
    if (versionCode.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_VERSIONCODE, versionCode.c_str());
    }
    
    if (model.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_MODEL, model.c_str());
    }
    
    if (manufacturer.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_DOLOGIN_MANUFACTURER, manufacturer.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDoLoginTask::SetParam( "
            "task : %p, "
            "token:%s,"
            "memberId:%s,"
            "deviceId:%s,"
            "versionCode:%s,"
            "model:%s,"
            "manufacturer:%s,"
            ")",
            this,
            token.c_str(),
            memberId.c_str(),
            deviceId.c_str(),
            versionCode.c_str(),
            model.c_str(),
            manufacturer.c_str()
            );
}



bool HttpDoLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDoLoginTask::ParseData( "
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
        
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnDoLogin(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

