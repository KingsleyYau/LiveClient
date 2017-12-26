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
    mVersionCode = "";
    mModel = "";
    mManufacturer = "";
    mEmail = "";
    mPassWord = "";
    mCheckCode = "";
    
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
                                     string versionCode,
                                     string model,
                                     string deviceid,
                                     string manufacturer,
                                     string checkCode
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
        mEmail = email;
    }
    
    if (passWord.length() > 0) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_PASSWORD, passWord.c_str());
        mPassWord = passWord;
    }
    
    if (versionCode.length() > 0) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_VERSIONCODE, versionCode.c_str());
        mVersionCode = versionCode;
    }
    if (checkCode.length() > 0) {
        mHttpEntiy.AddContent(OWN_EMAIL_LOGIN_CHECKCODE, checkCode.c_str());
        mCheckCode = checkCode;
    }
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnEmailLoginTask::SetParam( "
            "task : %p, "
            "email : %s "
            "password : %s "
            "versionCode : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            "checkCode: %s"
            ")",
            this,
            email.c_str(),
            passWord.c_str(),
            versionCode.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str(),
            checkCode.c_str()
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
    
    string sessionId = "alex123";
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[OWN_EMAIL_LOGIN_SESSIONID].isString()) {
                sessionId = dataJson[OWN_EMAIL_LOGIN_SESSIONID].asString();
            }
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
        mpCallback->OnOwnEmailLogin(this, bParse, errnum, errmsg, sessionId);
    }
    
    return bParse;
}
