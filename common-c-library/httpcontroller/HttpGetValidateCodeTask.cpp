 /*
 * HttpGetValidateCodeTask.cpp
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.22.获取验证码
 */

#include "HttpGetValidateCodeTask.h"
#include "HttpRequestConvertEnum.h"

HttpGetValidateCodeTask::HttpGetValidateCodeTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_VALIDATECODE_PATH;
}

HttpGetValidateCodeTask::~HttpGetValidateCodeTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetValidateCodeTask::SetCallback(IRequestGetValidateCodeCallback* callback) {
	mpCallback = callback;
}

void HttpGetValidateCodeTask::SetParam(
                                      LSValidateCodeType validateCodeType
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    mHttpEntiy.SetGetMethod(true);
    char temp[16];
    char tempUrl[2048] = {0};
    
    if (validateCodeType == LSVALIDATECODETYPE_FINDPW) {
        sprintf(temp, "findpw");
        mHttpEntiy.AddContent(LIVEROOM_VALIDATECODE_ID, temp);
    } else {
        sprintf(temp, "login");
        mHttpEntiy.AddContent(LIVEROOM_VALIDATECODE_ID, temp);
    }
    
    snprintf(tempUrl, sizeof(tempUrl), "%s?%s=%s", mPath.c_str(), LIVEROOM_VALIDATECODE_ID, temp);
    
    mPath = tempUrl;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetValidateCodeTask::SetParam( "
            "task : %p, "
            "validateCodeType : %d"
            ")",
            this,
            validateCodeType
            );
}

bool HttpGetValidateCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetValidateCodeTask::ParseData( "
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
    string memberId = "";
    string sid = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if (mpRequest->GetContentType().compare("image/png") == 0 )
        {
            bParse = true;
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
        }
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetValidateCode(this, bParse, errnum, errmsg, buf, size);
    }
    
    return bParse;
}

