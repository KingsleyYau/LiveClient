/*
 * HttpIOSGetPayTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.4.获取订单信息（仅iOS）
 */

#include "HttpIOSGetPayTask.h"

HttpIOSGetPayTask::HttpIOSGetPayTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_IOSPAY;
}

HttpIOSGetPayTask::~HttpIOSGetPayTask() {
	// TODO Auto-generated destructor stub
}

void HttpIOSGetPayTask::SetCallback(IRequestIOSGetPayCallback* callback) {
	mpCallback = callback;
}

void HttpIOSGetPayTask::SetParam(
                                 string manid,
                                 string sid,
                                 string number

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSPAY_MANID, manid.c_str());
    }
    
    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSPAY_SID, sid.c_str());
    }
    
    if( number.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_IOSPAY_NUMBER, number.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSGetPayTask::SetParam( "
            "task : %p, "
            "manid : %s "
            "sid : %s "
            "number : %s "
            ")",
            this,
            manid.c_str(),
            sid.c_str(),
            number.c_str()
            );
}



bool HttpIOSGetPayTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSGetPayTask::ParseData( "
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
        if (dataJson[LIVEROOM_IOSPAY_ORDERNO].isString()) {
            orderNo = dataJson[LIVEROOM_IOSPAY_ORDERNO].asString();
        }
        if (dataJson[LIVEROOM_IOSPAY_PRODUCTID].isString()) {
            productId = dataJson[LIVEROOM_IOSPAY_PRODUCTID].asString();
        }
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        code = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnIOSGetPay(this, bParse, code, orderNo, productId);
    }
    
    return bParse;
}

