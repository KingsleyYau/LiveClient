/*
 * HttpRegisterGetSMSCodeTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.2.获取手机注册短信验证码
 */

#include "HttpRegisterGetSMSCodeTask.h"

HttpRegisterGetSMSCodeTask::HttpRegisterGetSMSCodeTask() {
	// TODO Auto-generated constructor stub
    mPath = REGISTER_GET_SMSCODE;
    mPhoneNo = "";
    mAreaNo = "";
}

HttpRegisterGetSMSCodeTask::~HttpRegisterGetSMSCodeTask() {
	// TODO Auto-generated destructor stub
}

void HttpRegisterGetSMSCodeTask::SetCallback(IRequestRegisterGetSMSCodeCallback* callback) {
	mpCallback = callback;
}

void HttpRegisterGetSMSCodeTask::SetParam(
                                          string phoneNo,
                                          string areaNo
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
    
    
    FileLog("httpcontroller",
            "HttpRegisterCheckPhoneTask::SetParam( "
            "task : %p, "
            "phoneNo : %s, "
            "areaNo : %s, "
            ")",
            this,
            phoneNo.c_str(),
            areaNo.c_str()
            );
}

const string& HttpRegisterGetSMSCodeTask::GetPhoneNo() {
    return mPhoneNo;
}

const string& HttpRegisterGetSMSCodeTask::GetAreaNo() {
    return mAreaNo;
}

bool HttpRegisterGetSMSCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpRegisterGetSMSCodeTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpRegisterGetSMSCodeTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnRegisterGetSMSCode(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
