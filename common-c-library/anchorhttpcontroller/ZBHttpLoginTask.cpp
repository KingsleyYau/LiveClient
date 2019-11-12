/*
 * ZBHttpLoginTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 2.1.登录
 */

#include "ZBHttpLoginTask.h"
#include <common/CommonFunc.h>
#include "../common/md5.h"

ZBHttpLoginTask::ZBHttpLoginTask() {
    // TODO Auto-generated constructor stub
    mPath = LADYLOGIN_PATH;
    mSN = "";
    mPassword = "";
    mCode = "";
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
    mDeviceName = "";
}

ZBHttpLoginTask::~ZBHttpLoginTask() {
    // TODO Auto-generated destructor stub
}

void ZBHttpLoginTask::SetCallback(IRequestZBLoginCallback* callback) {
    mpCallback = callback;
}

void ZBHttpLoginTask::SetParam(
                               string anchorId,
                               string password,
                               string code,
                               string deviceid,
                               string model,
                               string manufacturer,
                               string deviceName
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LADYLOGIN_SN, anchorId.c_str());
        mSN = anchorId;
    }
    
    if (password.length() > 0) {
        mHttpEntiy.AddContent(LADYLOGIN_PASSWORD, password.c_str());
        mPassword = password;
    }
    
    if (code.length() > 0) {
        mHttpEntiy.AddContent(LADYLOGIN_CODE, code.c_str());
        mCode = code;
    }
    
    if( deviceid.length() > 0 ) {
        mHttpEntiy.AddContent(LADYLOGIN_DEVICEID, deviceid.c_str());
        mDeviceId = deviceid;
    }

    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(LADYLOGIN_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(LADYLOGIN_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }
    
    if( deviceName.length() > 0 ) {
        mHttpEntiy.AddContent(LADYLOGIN_DEVICENAME, deviceName.c_str());
        mDeviceName = deviceName;
    }

	FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpLoginTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "password : %s, "
            "code : %s, "
            "deviceid : %s, "
            "model : %s, "
            "manufacturer : %s, "
            "deviceName : %s "
            ")",
            this,
            anchorId.c_str(),
            password.c_str(),
            code.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str(),
            deviceName.c_str()
            );
}

bool ZBHttpLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpLoginTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    ZBHttpLoginItem item;
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBLogin(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
