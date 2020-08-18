/*
 * HttpSubmitPhoneVerifyCodeTask.cpp
 *
 *  Created on: 2017-10-13
 *      Author: Alex
 *        desc: 6.8.提交流媒体服务器测速结果
 */

#include "HttpServerSpeedTask.h"

HttpServerSpeedTask::HttpServerSpeedTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SUBMITSERVERVELOMETER;
    mSid = "";
    mRes = 0;
    mLiveRoomId = "";
}

HttpServerSpeedTask::~HttpServerSpeedTask() {
	// TODO Auto-generated destructor stub
}

void HttpServerSpeedTask::SetCallback(IRequestServerSpeedCallback* callback) {
	mpCallback = callback;
}

void HttpServerSpeedTask::SetParam(
                                   const string& sid,
                                   int res,
                                   const string& liveRoomId
                                   ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITSERVERVELOMETER_SID, sid.c_str());
        mSid = sid;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", res);
    mHttpEntiy.AddContent(LIVEROOM_SUBMITSERVERVELOMETER_RES, temp);
    mRes = res;
    
    if( liveRoomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITSERVERVELOMETER_LIVEROOMID, liveRoomId.c_str());
        mLiveRoomId = liveRoomId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpServerSpeedTask::SetParam( "
            "task : %p, "
            "sid : %s, "
            "res : %d, "
            "liveRoomId : %s"
            ")",
            this,
            sid.c_str(),
            res,
            liveRoomId.c_str()
            );
}

const string& HttpServerSpeedTask::GetSid() {
    return mSid;
}

int HttpServerSpeedTask::GetRes() {
    return mRes;
}

bool HttpServerSpeedTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpServerSpeedTask::ParseData( "
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
        mpCallback->OnServerSpeed(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

