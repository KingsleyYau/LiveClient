/*
 * HttpRegisterPhoneTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.3.手机注册 
 */

#include "HttpRegisterPhoneTask.h"
#include "common/md5.h"

HttpRegisterPhoneTask::HttpRegisterPhoneTask() {
	// TODO Auto-generated constructor stub
	mPath = REGISTER_PHOEN_REGISTER;
    mPhoneNo = "";
    mAreaNo = "";
    mCheckCode = "";
    mPassword = "";
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";

}

HttpRegisterPhoneTask::~HttpRegisterPhoneTask() {
	// TODO Auto-generated destructor stub
}

void HttpRegisterPhoneTask::SetCallback(IRequestRegisterPhoneCallback* callback) {
	mpCallback = callback;
}

void HttpRegisterPhoneTask::SetParam(
                                    string phoneNo,
                                    string areaNo,
                                    string checkCode,
                                    string password,
                                    string deviceId,
                                    string model,
                                    string manufacturer
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( phoneNo.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_PHONENO, phoneNo.c_str());
        mPhoneNo = phoneNo;
    }
    
    if( areaNo.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_AREANO, areaNo.c_str());
        mAreaNo = areaNo;
    }
    
    if( checkCode.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_CHECKCODE, checkCode.c_str());
        mCheckCode = checkCode;
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
        mHttpEntiy.AddContent(REGISTER_PASSWORD, md5);
        mPassword = password;
    }

    if( deviceId.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_DEVICEID, deviceId.c_str());
        mDeviceId = deviceId;
    }
    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }

    FileLog("httpcontroller",
            "HttpRegisterCheckPhoneTask::SetParam( "
            "task : %p, "
            "phoneNo : %s, "
            "areaNo : %s, "
            "checkCode : %s, "
            "password : %s, "
            "deviceId : %s, "
            "model : %s, "
            "manufacturer : %s, "
            ")",
            this,
            phoneNo.c_str(),
            areaNo.c_str(),
            checkCode.c_str(),
            password.c_str(),
            deviceId.c_str(),
            model.c_str(),
            manufacturer.c_str()
            );
}

const string& HttpRegisterPhoneTask::GetPhoneNo() {
    return mPhoneNo;
}

const string& HttpRegisterPhoneTask::GetAreaNo() {
    return mAreaNo;
}

const string& HttpRegisterPhoneTask::GetCheckCode() {
    return mCheckCode;
}

const string& HttpRegisterPhoneTask::GetPassword() {
    return mPassword;
}

const string& HttpRegisterPhoneTask::GetDeviceId() {
    return mDeviceId;
}

const string& HttpRegisterPhoneTask::GetModel() {
    return mModel;
}

const string& HttpRegisterPhoneTask::GetManufacturer() {
    return mManufacturer;
}

bool HttpRegisterPhoneTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpRegisterPhoneTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpRegisterPhoneTask::ParseData( buf : %s )", buf);
    }
    
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
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnRegisterPhone(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
