/*
 * HttpManBookingUnreadUnhandleNumTask.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.4.获取预约邀请未读或待处理数量
 */

#include "HttpManBookingUnreadUnhandleNumTask.h"

HttpManBookingUnreadUnhandleNumTask::HttpManBookingUnreadUnhandleNumTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_MANBOOKINGUNREADUNHANDKENUM ;
}

HttpManBookingUnreadUnhandleNumTask::~HttpManBookingUnreadUnhandleNumTask() {
	// TODO Auto-generated destructor stub
}

void HttpManBookingUnreadUnhandleNumTask::SetCallback(IRequestManBookingUnreadUnhandleNumCallback* callback) {
	mpCallback = callback;
}


void HttpManBookingUnreadUnhandleNumTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog("httpcontroller",
            "HttpManBookingUnreadUnhandleNumTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpManBookingUnreadUnhandleNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpManBookingUnreadUnhandleNumTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpManBookingUnreadUnhandleNumTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpBookingUnreadUnhandleNumItem item;
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
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnManBookingUnreadUnhandleNum(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

