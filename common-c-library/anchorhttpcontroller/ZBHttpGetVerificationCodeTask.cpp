/*
 * ZBHttpGetVerificationCodeTask.cpp
 *
 *  Created on: 2018-02-27
 *      Author: Alex
 *        desc: 2.30.获取验证码（仅独立）
 */

#include "ZBHttpGetVerificationCodeTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"


ZBHttpGetVerificationCodeTask::ZBHttpGetVerificationCodeTask() {
    // TODO Auto-generated constructor stub
    mPath = GETVERIFICATIONCODE_PATH;
   
}

ZBHttpGetVerificationCodeTask::~ZBHttpGetVerificationCodeTask() {
    // TODO Auto-generated destructor stub
}

void ZBHttpGetVerificationCodeTask::SetCallback(IRequestZBGetVerificationCodeCallback* callback) {
    mpCallback = callback;
}

void ZBHttpGetVerificationCodeTask::SetParam(

                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
 
	FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetVerificationCodeTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool ZBHttpGetVerificationCodeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetVerificationCodeTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpGetVerificationCodeTask::ParseData( buf : %s )", buf);
    }
    
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;

    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBGetVerificationCode(this, bParse, errnum, errmsg, buf, size);
    }
    
    return bParse;
}
