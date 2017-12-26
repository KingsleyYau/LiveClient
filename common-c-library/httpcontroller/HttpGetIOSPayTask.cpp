/*
 * HttpGetIOSPayTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 7.2.获取订单信息（仅独立）（仅iOS）
 */

#include "HttpGetIOSPayTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpGetIOSPayTask::HttpGetIOSPayTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_ORDER_IOSPAY;
    mManid = "";
    mSid = "";
    mNumber = "";
    mSiteid = "";
   
}

HttpGetIOSPayTask::~HttpGetIOSPayTask() {
    // TODO Auto-generated destructor stub
}

void HttpGetIOSPayTask::SetCallback(IRequestGetIOSPayCallback* callback) {
    mpCallback = callback;
}

void HttpGetIOSPayTask::SetParam(
                                 string manid,
                                 string sid,
                                 string number,
                                 string siteid
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSPAY_MANID, manid.c_str());
        mManid = manid;
    }
    
    if( sid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSPAY_SID, sid.c_str());
        mSid = sid;
    }
    
    if( number.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSPAY_NUMBER, number.c_str());
        mNumber = number;
    }
    
    if( siteid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ORDER_IOSPAY_SITED, siteid.c_str());
        mSiteid = siteid;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetIOSPayTask::SetParam( "
            "task : %p, "
            "manid : %s "
            "sid : %s "
            "number : %s "
            "siteid : %s "
            ")",
            this,
            manid.c_str(),
            sid.c_str(),
            number.c_str(),
            siteid.c_str()
            );
}


bool HttpGetIOSPayTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetIOSPayTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetIOSPayTask::ParseData( buf : %s )", buf);
    }
    
    //int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    string code = "";
    string orderNo = "alextestOrderNo";
    string productId = "alextestProductId";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        // 买点的字段不同
        if ((bParse = ParseIOSPaid(buf, size, code, &dataJson))) {
            if (dataJson[LIVEROOM_ORDER_IOSPAY_ORDERNO].isString()) {
                orderNo = dataJson[LIVEROOM_ORDER_IOSPAY_ORDERNO].asString();
            }
            if (dataJson[LIVEROOM_ORDER_IOSPAY_PRODUCTID].isString()) {
                productId = dataJson[LIVEROOM_ORDER_IOSPAY_PRODUCTID].asString();
            }
        }
        
        // LSalextest
        if (bParse == false) {
            errmsg = "";
            bParse = true;
        }
        
    } else {
//        // 超时
//        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
        // LSalextest
        errmsg = "";
        bParse = true;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetIOSPay(this, bParse, errmsg, orderNo, productId);
    }
    
    return bParse;
}
