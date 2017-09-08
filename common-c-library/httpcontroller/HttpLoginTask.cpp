/*
 * HttpLoginTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 2.1.登录
 */

#include "HttpLoginTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpLoginTask::HttpLoginTask() {
    // TODO Auto-generated constructor stub
    mPath = STREAMLOGIN_PATH;
    mQnsid = "";
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
}

HttpLoginTask::~HttpLoginTask() {
    // TODO Auto-generated destructor stub
}

void HttpLoginTask::SetCallback(IRequestLoginCallback* callback) {
    mpCallback = callback;
}

void HttpLoginTask::SetParam(
                                   string qnsid,
                                   string deviceid,
                                   string model,
                                   string manufacturer
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    if (qnsid.length() > 0) {
        mHttpEntiy.AddContent(LOGIN_QNSID, qnsid.c_str());
        mQnsid = qnsid;
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

	FileLog("httpcontroller",
            "HttpStreamLoginTask::SetParam( "
            "task : %p, "
            "qnsid : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            ")",
            this,
            qnsid.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str()
            );
}



/**
 * 获取QN系统登录验证返回的标识
 */
const string& HttpLoginTask::GetQnsid() {
    return mQnsid;
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
