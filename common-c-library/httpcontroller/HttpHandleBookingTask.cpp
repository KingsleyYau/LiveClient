/*
 * HttpHandleBookingTask.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.2.观众处理预约邀请
 */

#include "HttpHandleBookingTask.h"

HttpHandleBookingTask::HttpHandleBookingTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_HANDLEBOOKING;
    mInviteId = "";
    mIsConfirm = false;
}

HttpHandleBookingTask::~HttpHandleBookingTask() {
	// TODO Auto-generated destructor stub
}

void HttpHandleBookingTask::SetCallback(IRequestHandleBookingCallback* callback) {
	mpCallback = callback;
}


void HttpHandleBookingTask::SetParam(
                                     string inviteId,
                                     bool isConfirm
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (inviteId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_HANDLEBOOKINGT_INVITATIONID, inviteId.c_str());
        mInviteId = inviteId;
    }

    char temp[16];
    snprintf(temp, sizeof(temp), "%d", isConfirm ? 1 : 0);
    mHttpEntiy.AddContent(LIVEROOM_HANDLEBOOKINGT_ISCONFIRM, temp);
    mIsConfirm = isConfirm;
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpHandleBookingTask::SetParam( "
            "task : %p, "
            "inviteId :%s, "
            "isConfirm : %d, "
            ")",
            this,
            inviteId.c_str(),
            isConfirm
            );
}


string HttpHandleBookingTask::GetInviteId() {
    return mInviteId;
}

bool HttpHandleBookingTask::GetIsConfirm() {
    return mIsConfirm;
}

bool HttpHandleBookingTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpHandleBookingTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpHandleBookingTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnHandleBooking(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

