/*
 * HttpGetVerificationCodeTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 2.10.获取验证码（仅独立）
 */

#include "HttpGetVerificationCodeTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"
/**
 * 验证类型
 * 2.默认为首次验证，3.下單驗證（可选字段）
 */
#define VerifyArrayCount 2
string VerifyArray[VerifyArrayCount] = {
    "login",
    "findpw",
};

HttpGetVerificationCodeTask::HttpGetVerificationCodeTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_GIFAUTH_PATH;
    mVerifyType = VERIFYCODETYPE_LOGIN;
    mUseCode = false;
   
}

HttpGetVerificationCodeTask::~HttpGetVerificationCodeTask() {
    // TODO Auto-generated destructor stub
}

void HttpGetVerificationCodeTask::SetCallback(IRequestGetVerificationCodeCallback* callback) {
    mpCallback = callback;
}

void HttpGetVerificationCodeTask::SetParam(
                                           VerifyCodeType verifyType,
                                           bool   useCode
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    mHttpEntiy.AddContent(OWN_GIFAUTH_ID, VerifyArray[verifyType]);
    mVerifyType = verifyType;
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", useCode == true ? 1 : 0);
    mHttpEntiy.AddContent(OWN_GIFAUTH_USECODE, temp);
    mUseCode = useCode;

    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetVerificationCodeTask::SetParam( "
            "task : %p, "
            "verifyType : %d "
            "useCode : %d "
            ")",
            this,
            verifyType,
            useCode
            );
}


bool HttpGetVerificationCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetVerificationCodeTask::ParseData( "
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
        // 数据只有二进制图片，不需要解析
//        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
//            //bParse = true;
//        }
        if (mpRequest->GetContentType().compare("image/png") == 0 )
        {
            bParse = true;
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
        }
        
       // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;

    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetVerificationCode(this, bParse, errnum, errmsg, buf, size);
    }
    
    return bParse;
}
