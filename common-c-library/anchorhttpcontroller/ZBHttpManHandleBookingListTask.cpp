/*
 * ZBHttpManHandleBookingListTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.1.获取预约邀请列表
 */

#include "ZBHttpManHandleBookingListTask.h"

ZBHttpManHandleBookingListTask::ZBHttpManHandleBookingListTask() {
	// TODO Auto-generated constructor stub
	mPath = MANHANDLEBOOKINGLIST_PATH;
    mType = ZBBOOKINGLISTTYPE_WAITANCHORHANDLEING;
    mStart = 0;
    mStep = 0;
}

ZBHttpManHandleBookingListTask::~ZBHttpManHandleBookingListTask() {
	// TODO Auto-generated destructor stub
}

int ZBHttpManHandleBookingListTask::GetStart() {
    return mStart;
}

ZBBookingListType ZBHttpManHandleBookingListTask::GetType() {

    return mType;
}

int ZBHttpManHandleBookingListTask::GetStep() {
    return mStep;
}


void ZBHttpManHandleBookingListTask::SetCallback(IRequestZBManHandleBookingListCallback* callback) {
	mpCallback = callback;
}

void ZBHttpManHandleBookingListTask::SetParam(
                                            ZBBookingListType type,
                                            int start,
                                            int step
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", type);
    mHttpEntiy.AddContent(MANHANDLEBOOKINGLIST_TAG, temp);
    mType = type;
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(MANHANDLEBOOKINGLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(MANHANDLEBOOKINGLIST_STEP, temp);
    mStep = step;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpManHandleBookingListTask::SetParam( "
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


bool ZBHttpManHandleBookingListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpManHandleBookingListTask::ParseData( "
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
    ZBHttpBookingInviteListItem BookingListItem;
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBManHandleBookingList(this, bParse, errnum, errmsg, BookingListItem);
    }
    
    return bParse;
}

