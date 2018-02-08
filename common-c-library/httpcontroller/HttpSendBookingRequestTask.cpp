/*
 * HttpSendBookingRequestTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 4.6.新建预约邀请
 */

#include "HttpSendBookingRequestTask.h"

HttpSendBookingRequestTask::HttpSendBookingRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SENDBOOKINGREQUEST;
    mUserId = "";
    mTimeId = "";
    mBookTime = 0;
    mGiftId = "";
    mGiftNum = 0;
    mNeedSms = false;
}

HttpSendBookingRequestTask::~HttpSendBookingRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendBookingRequestTask::SetCallback(IRequestSendBookingRequestCallback* callback) {
	mpCallback = callback;
}

void HttpSendBookingRequestTask::SetParam(
                                          const string userId,
                                          const string timeId,
                                          long bookTime,
                                          const string giftId,
                                          int giftNum,
                                          bool needSms
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( userId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_USERID, userId.c_str());
        mUserId = userId;
    }
    
    if( timeId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_TIMEID, timeId.c_str());
        mTimeId = timeId;
    }
  
    char temp[16];
    snprintf(temp, sizeof(temp), "%ld", bookTime);
    mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_BOOKTIME, temp);
    mBookTime = bookTime;
 
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_GIFTID, giftId.c_str());
        mGiftId = giftId;
        
        snprintf(temp, sizeof(temp), "%d", giftNum);
        mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_GIFTNUM, temp);
        mGiftNum = giftNum;
        
    }
    

    
    snprintf(temp, sizeof(temp), "%d", needSms == false ? 0 : 1);
    mHttpEntiy.AddContent(LIVEROOM_SENDBOOKINGREQUEST_NEEDSMS, temp);
    mNeedSms = needSms;

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendBookingRequestTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


const string& HttpSendBookingRequestTask::GetUserId() {
    return mUserId;
}

const string& HttpSendBookingRequestTask::GetTimeId() {
    return mTimeId;
}

long HttpSendBookingRequestTask::GetBookTime() {
    return mBookTime;
}

const string& HttpSendBookingRequestTask::GetGiftId() {
    return mGiftId;
}

int HttpSendBookingRequestTask::GetGiftNum() {
    return mGiftNum;
}

bool  HttpSendBookingRequestTask::GetNeedSms() {
    return mNeedSms;
}


bool HttpSendBookingRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendBookingRequestTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSendBookingRequestTask::ParseData( buf : %s )", buf);
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
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSendBookingRequest(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

