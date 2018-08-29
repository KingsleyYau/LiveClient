/*
 * HttpGetPhoneVerifyCodeTask.cpp
 *
 *  Created on: 2017-9-25
 *      Author: Alex
 *        desc: 6.6.获取手机验证码
 */

#include "HttpGetPhoneVerifyCodeTask.h"

HttpGetPhoneVerifyCodeTask::HttpGetPhoneVerifyCodeTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETPHONEVERIFYCODE;
    mCountry = "";
    mAreaCode = "";
    mPhoneNo = "";

}

HttpGetPhoneVerifyCodeTask::~HttpGetPhoneVerifyCodeTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPhoneVerifyCodeTask::SetCallback(IRequestGetPhoneVerifyCodeCallback* callback) {
	mpCallback = callback;
}

void HttpGetPhoneVerifyCodeTask::SetParam(
                                          const string& country,
                                          const string& areaCode,
                                          const string& phoneNo
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    if( country.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETPHONEVERIFYCODE_COUNTRY, country.c_str());
        mCountry = country;
    }
    
    if( areaCode.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETPHONEVERIFYCODE_AREACODE, areaCode.c_str());
        mAreaCode = areaCode;
    }
  
    if( phoneNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETPHONEVERIFYCODE_PHONENO, phoneNo.c_str());
        mPhoneNo = phoneNo;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPhoneVerifyCodeTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpGetPhoneVerifyCodeTask::GetCountry() {
    return mCountry;
}

const string& HttpGetPhoneVerifyCodeTask::GetAreaCode() {
    return mAreaCode;
}

const string& HttpGetPhoneVerifyCodeTask::GetPhoneNo() {
    return mPhoneNo;
}


bool HttpGetPhoneVerifyCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPhoneVerifyCodeTask::ParseData( "
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
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetPhoneVerifyCode(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

