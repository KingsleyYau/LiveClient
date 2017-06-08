/*
 * HttpLoginTask.cpp
 *
 *  Created on: 2017-5-19
 *      Author: Alex
 *        desc: 2.4.登录
 */

#include "HttpLoginTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpLoginTask::HttpLoginTask() {
    // TODO Auto-generated constructor stub
    mPath = STREAMLOGIN_PATH;
    mType = LoginType_Unknow;
    mPhoneNo = "";
    mAreNo = "";
    mPassword = "";
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
    mAutoLogin = false;
}

HttpLoginTask::~HttpLoginTask() {
    // TODO Auto-generated destructor stub
}

void HttpLoginTask::SetCallback(IRequestLoginCallback* callback) {
    mpCallback = callback;
}

void HttpLoginTask::SetParam(
                                   LoginType    type,
                                   string phoneno,
                                   string areno,
                                   string password,
                                   string deviceid,
                                   string model,
                                   string manufacturer,
                                   bool autoLogin
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    string strType("");
    if( type < _countof(OTHER_LOGIN_TYPE)) {
        strType = OTHER_LOGIN_TYPE[type];
        mHttpEntiy.AddContent(LOGIN_TYPE, strType.c_str());
        mType = type;
    }
    
    // 手机登录
    if( type == 0 ) {
        if( phoneno.length() > 0 ) {
            mHttpEntiy.AddContent(LOGIN_PHONENO, phoneno.c_str());
            mPhoneNo = phoneno;
        }
        
        if( areno.length() > 0 ) {
            mHttpEntiy.AddContent(LOGIN_ARENO, areno.c_str());
            mAreNo = areno;
        }
    }
    
    if( password.length() > 0 ) {
        
        // 大写转小写
        for (int i = 0; i < password.length(); i++) {
            if (password[i] >= 'A' && password[i] <= 'Z') {
                password[i] =  password[i] + 'a' - 'A';
            }
        }
        char md5[128] = {0};
        GetMD5String(password.c_str(), md5);
        mHttpEntiy.AddContent(LOGIN_PASSWORD, md5);
        mPassword = password;
    }
    
    if( deviceid.length() > 0 ) {
        mHttpEntiy.AddContent(LOGIN_DEVICEID, deviceid.c_str());
        mDeviceId = deviceid;
    }

    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(LOGIN_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(LOGIN_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", autoLogin ? 1 : 0);
    mHttpEntiy.AddContent(LOGIN_AUTOLOGIN, temp);
    mAutoLogin = autoLogin;
    
    FileLog("httpcontroller",
            "HttpStreamLoginTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "phoneno : %s "
            "areno : %s "
            "password : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            "autoLogin :%d"
            ")",
            this,
            type,
            phoneno.c_str(),
            areno.c_str(),
            password.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str(),
            autoLogin
            );
}


/**
 * 获取登录类型（0: 手机登录 1:邮箱登录）
 */
int HttpLoginTask::GetType() {
    return mType;
}

/**
 * 获取手机号码（仅当type ＝ 0 时使用）
 */
const string& HttpLoginTask::GetPhoneNo() {
    return mPhoneNo;
}
/**
 * 获取手机区号（仅当type ＝ 0 时使用）
 */
const string& HttpLoginTask::GetAreNo() {
    return mAreNo;
}

/**
 * 获取登录密码
 */
const string& HttpLoginTask::GetPassword() {
    return mPassword;
}

/**
 * 获取设备唯一标识
 */
const string& HttpLoginTask::GetDeviceId() {
    return mDeviceId;
}

/**
 * 获取设备型号（格式：设备型号－系统版本号）
 */
const string& HttpLoginTask::GetModel() {
    return mModel;
}

/**
 * 获取设备型号（格式：设备型号－系统版本号）
 */
const string& HttpLoginTask::GetManufacturer() {
    return mManufacturer;
}

bool HttpLoginTask::GetAutoLogin() {
    return mAutoLogin;
}

bool HttpLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpStreamLoginTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpStreamLoginTask::ParseData( buf : %s )", buf);
    }
    
    HttpLoginItem item;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            // 业务解析
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnLogin(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
