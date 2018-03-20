/*
 * ZBHttpServerSpeedTask.cpp
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 5.3.提交流媒体服务器测速结果
 */

#include "ZBHttpServerSpeedTask.h"

ZBHttpServerSpeedTask::ZBHttpServerSpeedTask() {
	// TODO Auto-generated constructor stub
	mPath = SUBMITSERVERVELOMETER_PATH;
    mSid = "";
    mRes = 0;
}

ZBHttpServerSpeedTask::~ZBHttpServerSpeedTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpServerSpeedTask::SetCallback(IRequestZBServerSpeedCallback* callback) {
	mpCallback = callback;
}

void ZBHttpServerSpeedTask::SetParam(
                                   const string& sid,
                                   int res
                                   ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(SUBMITSERVERVELOMETER_SID, sid.c_str());
        mSid = sid;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", res);
    mHttpEntiy.AddContent(SUBMITSERVERVELOMETER_RES, temp);
    mRes = res;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpServerSpeedTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& ZBHttpServerSpeedTask::GetSid() {
    return mSid;
}

int ZBHttpServerSpeedTask::GetRes() {
    return mRes;
}

bool ZBHttpServerSpeedTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpServerSpeedTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpSubmitPhoneVerifyCodeTask::ParseData( buf : %s )", buf);
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBServerSpeed(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

