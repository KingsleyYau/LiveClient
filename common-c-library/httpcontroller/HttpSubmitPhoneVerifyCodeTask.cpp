/*
 * HttpSubmitPhoneVerifyCodeTask.cpp
 *
 *  Created on: 2017-9-25
 *      Author: Alex
 *        desc: 6.7.提交手机验证码
 */

#include "HttpSubmitPhoneVerifyCodeTask.h"

HttpSubmitPhoneVerifyCodeTask::HttpSubmitPhoneVerifyCodeTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SUBMITPHONEVERIFYCODE;
    mCountry = "";
    mAreaCode = "";
    mPhoneNo = "";
    mVerifyCode = "";

}

HttpSubmitPhoneVerifyCodeTask::~HttpSubmitPhoneVerifyCodeTask() {
	// TODO Auto-generated destructor stub
}

void HttpSubmitPhoneVerifyCodeTask::SetCallback(IRequestSubmitPhoneVerifyCodeCallback* callback) {
	mpCallback = callback;
}

void HttpSubmitPhoneVerifyCodeTask::SetParam(
                                          const string& country,
                                          const string& areaCode,
                                          const string& phoneNo,
                                          const string& verifyCode
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    if( country.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITPHONEVERIFYCODE_COUNTRY, country.c_str());
        mCountry = country;
    }
    
    if( areaCode.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITPHONEVERIFYCODE_AREACODE, areaCode.c_str());
        mAreaCode = areaCode;
    }
  
    if( phoneNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITPHONEVERIFYCODE_PHONENO, phoneNo.c_str());
        mPhoneNo = phoneNo;
    }
    
    if( verifyCode.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITPHONEVERIFYCODE_VERIFYCODE, verifyCode.c_str());
        mVerifyCode = verifyCode;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSubmitPhoneVerifyCodeTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpSubmitPhoneVerifyCodeTask::GetCountry() {
    return mCountry;
}

const string& HttpSubmitPhoneVerifyCodeTask::GetAreaCode() {
    return mAreaCode;
}

const string& HttpSubmitPhoneVerifyCodeTask::GetPhoneNo() {
    return mPhoneNo;
}

const string& HttpSubmitPhoneVerifyCodeTask::GetVerifyCode() {
    return mVerifyCode;
}


bool HttpSubmitPhoneVerifyCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSubmitPhoneVerifyCodeTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSubmitPhoneVerifyCodeTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnSubmitPhoneVerifyCode(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

