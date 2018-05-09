/*
 * HttpOwnEmailLoginTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.6.邮箱登录（仅独立）
 */

#include "HttpOwnEmailLoginTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpOwnEmailLoginTask::HttpOwnEmailLoginTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_EMAIL_LOGIN_PATH;
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
    mEmail = "";
    mPassWord = "";
    
}

HttpOwnEmailLoginTask::~HttpOwnEmailLoginTask() {
    // TODO Auto-generated destructor stub
}

void HttpOwnEmailLoginTask::SetCallback(IRequestOwnEmailLoginCallback* callback) {
    mpCallback = callback;
}

void HttpOwnEmailLoginTask::SetParam(
                                     string email,
                                     string passWord,
                                     string model,
                                     string deviceid,
                                     string manufacturer
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( deviceid.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_DEVICEID, deviceid.c_str());
        mDeviceId = deviceid;
    }
    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }
    
    if (email.length() > 0) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_EMAIL, email.c_str());
        //mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_EMAIL, "CMTS09585");
        mEmail = email;
    }
    
    if (passWord.length() > 0) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_PASSWORD, passWord.c_str());
        mPassWord = passWord;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnEmailLoginTask::SetParam( "
            "task : %p, "
            "email : %s "
            "password : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            ")",
            this,
            email.c_str(),
            passWord.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str()
            );
}


bool HttpOwnEmailLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnEmailLoginTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpOwnEmailLoginTask::ParseData( buf : %s )", buf);
    }
    
    string sessionId = "";
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                if (dataJson[OWN_EMAIL_LOGIN_SESSIONID].isString()) {
                    sessionId = dataJson[OWN_EMAIL_LOGIN_SESSIONID].asString();
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
        mpCallback->OnOwnEmailLogin(this, bParse, errnum, errmsg, sessionId);
    }
    
    return bParse;
}
