/*
 * HttpGetAppPayTask.cpp
 *
 *  Created on: 2019-12-06
 *      Author: Alex
 *        desc: 16.1.获取我司订单号（仅Android）
 */

#include "HttpGetAppPayTask.h"

HttpGetAppPayTask::HttpGetAppPayTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_APPPAY;
}

HttpGetAppPayTask::~HttpGetAppPayTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAppPayTask::SetCallback(IRequestGetAppPayCallback* callback) {
	mpCallback = callback;
}

void HttpGetAppPayTask::SetParam(
                                 string number

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( number.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_APPPAY_NUMBER, number.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAppPayTask::SetParam( "
            "task : %p, "
            "number : %s "
            ")",
            this,
            number.c_str()
            );
}



bool HttpGetAppPayTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAppPayTask::ParseData( "
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
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseAndroidPaid(buf, size, code, errmsg, &dataJson);
        if (dataJson[LIVEROOM_APPPAY_ORDERNO].isString()) {
            orderNo = dataJson[LIVEROOM_APPPAY_ORDERNO].asString();
        }
        if (dataJson[LIVEROOM_APPPAY_PRODUCTID].isString()) {
            productId = dataJson[LIVEROOM_APPPAY_PRODUCTID].asString();
        }
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        code = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetAppPay(this, bParse, code, errmsg, orderNo, productId);
    }
    
    return bParse;
}

