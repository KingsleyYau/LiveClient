/*
 * HttpSetRideTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.4.使用／取消座驾
 */

#include "HttpSetRideTask.h"

HttpSetRideTask::HttpSetRideTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SETRIDE;
    mRideId = "";
}

HttpSetRideTask::~HttpSetRideTask() {
	// TODO Auto-generated destructor stub
}

void HttpSetRideTask::SetCallback(IRequestSetRideCallback* callback) {
	mpCallback = callback;
}

void HttpSetRideTask::SetParam(
                                const string& rideId
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( rideId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SETRIDE_RIDEID, rideId.c_str());
        mRideId = rideId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetRideTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpSetRideTask::GetRideId() {
    return mRideId;
}

bool HttpSetRideTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetRideTask::ParseData( "
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
        mpCallback->OnSetRide(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

