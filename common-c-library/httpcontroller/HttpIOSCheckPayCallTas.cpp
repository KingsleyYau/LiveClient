/*
 * HttpIOSCheckPayCallTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.5.验证订单信息（仅iOS）
 */

#include "HttpIOSCheckPayCallTask.h"

HttpIOSCheckPayCallTask::HttpIOSCheckPayCallTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_IOSCALLBACK;
}

HttpIOSCheckPayCallTask::~HttpIOSCheckPayCallTask() {
	// TODO Auto-generated destructor stub
}

void HttpIOSCheckPayCallTask::SetCallback(IRequestIOSCheckPayCallCallback* callback) {
	mpCallback = callback;
}

void HttpIOSCheckPayCallTask::SetParam(
                                       string manid,
                                       string sid,
                                       string receipt,
                                       string orderNo,
                                       AppStorePayCodeType code

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSCALLBACK_MANID, manid.c_str());

    }
    
    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSCALLBACK_SID, sid.c_str());

    }
    
    if( receipt.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSCALLBACK_RECEIPT, receipt.c_str());

    }
    
    if( orderNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSCALLBACK_ORDERNO, orderNo.c_str());

    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", (code > APPSTOREPAYTYPE_UNKNOW && code <= APPSTOREPAYTYPE_NOIMMEDIATELYPAY) ? code : APPSTOREPAYTYPE_PAYSUCCES);
    mHttpEntiy.AddContent(LIVEROOM_IOSCALLBACK_CODE, temp);

    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSCheckPayCallTask::SetParam( "
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



bool HttpIOSCheckPayCallTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSCheckPayCallTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errmsg = "";
    string code = "";
    string orderNo = "";
    string productId = "";
    bool bParse = false;
    HttpOrderProductItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseIOSPaid(buf, size, code, &dataJson);
        if (bParse) {
            if (dataJson[LIVEROOM_IOSPAY_ORDERNO].isString()) {
                orderNo = dataJson[LIVEROOM_IOSPAY_ORDERNO].asString();
            }
            if (dataJson[LIVEROOM_IOSPAY_PRODUCTID].isString()) {
                productId = dataJson[LIVEROOM_IOSPAY_PRODUCTID].asString();
            }
        }
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        code = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnIOSCheckPayCall(this, bParse, errmsg);
    }
    
    return bParse;
}

