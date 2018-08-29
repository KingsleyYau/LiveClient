/*
 * HttpGetCreateBookingInfoTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 4.5.获取新建预约邀请信息
 */

#include "HttpGetCreateBookingInfoTask.h"

HttpGetCreateBookingInfoTask::HttpGetCreateBookingInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCREATEBOOKINGINFO;
    mUserId = "";
}

HttpGetCreateBookingInfoTask::~HttpGetCreateBookingInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCreateBookingInfoTask::SetCallback(IRequestGetCreateBookingInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetCreateBookingInfoTask::SetParam(
                                        const string& userId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( userId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETCREATEBOOKINGINFO_USERID, userId.c_str());
        mUserId = userId;
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCreateBookingInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


const string& HttpGetCreateBookingInfoTask::GetUserId() {
    return mUserId;
}


bool HttpGetCreateBookingInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCreateBookingInfoTask::ParseData( "
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
    HttpGetCreateBookingInfoItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetCreateBookingInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

