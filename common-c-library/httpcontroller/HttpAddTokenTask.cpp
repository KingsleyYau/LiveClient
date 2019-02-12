/*
 * HttpAddTokenTaskcpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.14.添加App token
 */

#include "HttpAddTokenTask.h"

HttpAddTokenTask::HttpAddTokenTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ADDTOKEN_PATH;


}

HttpAddTokenTask::~HttpAddTokenTask() {
	// TODO Auto-generated destructor stub
}

void HttpAddTokenTask::SetCallback(IRequestAddTokenCallback* callback) {
	mpCallback = callback;
}

void HttpAddTokenTask::SetParam(
                                const string& token,
                                const string& appId,
                                const string& deviceId
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (token.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ADDTOKEN_TOKEN, token.c_str());
    }

    if (appId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ADDTOKEN_APPID, appId.c_str());
    }
    
    if (deviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ADDTOKEN_DEVICEID, deviceId.c_str());
    }
    


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddTokenTask::SetParam( "
            "task : %p, "
            "token:%s,"
            "appId:%s,"
            "deviceId:%s,"
            ")",
            this,
            token.c_str(),
            appId.c_str(),
            deviceId.c_str()
            );
}



bool HttpAddTokenTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddTokenTask::ParseData( "
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
        mpCallback->OnAddToken(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

