/*
 * HttpManHandleBookingListTask.cpp
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.1.观众待处理的预约邀请列表
 */

#include "HttpManHandleBookingListTask.h"

HttpManHandleBookingListTask::HttpManHandleBookingListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_MANHANDLEBOOKINGLIST;
    mType = BOOKINGLISTTYPE_WAITFANSHANDLEING;
    mStart = 0;
    mStep = 0;
}

HttpManHandleBookingListTask::~HttpManHandleBookingListTask() {
	// TODO Auto-generated destructor stub
}

int HttpManHandleBookingListTask::GetStart() {
    return mStart;
}

BookingListType HttpManHandleBookingListTask::GetType() {

    return mType;
}

int HttpManHandleBookingListTask::GetStep() {
    return mStep;
}


void HttpManHandleBookingListTask::SetCallback(IRequestManHandleBookingListCallback* callback) {
	mpCallback = callback;
}

void HttpManHandleBookingListTask::SetParam(
                                            BookingListType type,
                                            int start,
                                            int step
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", type);
    mHttpEntiy.AddContent(LIVEROOM_MANHANDLEBOOKINGLIST_TAG, temp);
    mType = type;
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_MANHANDLEBOOKINGLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_MANHANDLEBOOKINGLIST_STEP, temp);
    mStep = step;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpManHandleBookingListTask::SetParam( "
            "task : %p, "
            "type :%d, "
            "start : %d, "
            "step : %d, "
            ")",
            this,
            type,
            start,
            step
            );
}


bool HttpManHandleBookingListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpManHandleBookingListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpManHandleBookingListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpBookingInviteListItem BookingListItem;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            BookingListItem.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnManHandleBookingList(this, bParse, errnum, errmsg, BookingListItem);
    }
    
    return bParse;
}

