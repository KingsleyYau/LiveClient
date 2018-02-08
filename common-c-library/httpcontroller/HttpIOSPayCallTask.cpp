/*
 * HttpIOSPayCallTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 7.3.验证订单信息（仅独立）（仅iOS）
 */

#include "HttpIOSPayCallTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpIOSPayCallTask::HttpIOSPayCallTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_ORDER_IOSCALLBACK;
    mManid = "";
    mSid = "";
    mReceipt = "";
    mOrderno = "";
    mCode = APPSTOREPAYTYPE_PAYSUCCES;
   
}

HttpIOSPayCallTask::~HttpIOSPayCallTask() {
    // TODO Auto-generated destructor stub
}

void HttpIOSPayCallTask::SetCallback(IRequestIOSPayCallCallback* callback) {
    mpCallback = callback;
}

void HttpIOSPayCallTask::SetParam(
                                  string manid,
                                  string sid,
                                  string receipt,
                                  string orderNo,
                                  AppStorePayCodeType code
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSCALLBACK_MANID, manid.c_str());
        mManid = manid;
    }
    
    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSCALLBACK_SID, sid.c_str());
        mSid = sid;
    }
    
    if( receipt.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSCALLBACK_RECEIPT, receipt.c_str());
        mReceipt = receipt;
    }
    
    if( orderNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSCALLBACK_ORDERNO, orderNo.c_str());
        orderNo = orderNo;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", (code > APPSTOREPAYTYPE_UNKNOW && code <= APPSTOREPAYTYPE_NOIMMEDIATELYPAY) ? code : APPSTOREPAYTYPE_PAYSUCCES);
    mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSCALLBACK_CODE, temp);
    mCode = code;
    
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSPayCallTask::SetParam( "
            "task : %p, "
            "manid : %s "
            "sid : %s "
            "receipt : %s "
            "orderNo : %s "
            "code : %d"
            ")",
            this,
            manid.c_str(),
            sid.c_str(),
            receipt.c_str(),
            orderNo.c_str(),
            code
            );
}


bool HttpIOSPayCallTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSPayCallTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpIOSPayCallTask::ParseData( buf : %s )", buf);
    }
    
    //int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    string code = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        // 买点的字段不同
        if ((bParse = ParseIOSPaid(buf, size, code, &dataJson))) {
        }
         
        
    } else {
        // 超时
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnIOSPayCall(this, bParse, errmsg);
    }
    
    return bParse;
}
