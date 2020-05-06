/*
 * HttpAndroidPremiumMemberShipTask.cpp
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.2.获取商品列表（仅Android）
 */

#include "HttpAndroidPremiumMemberShipTask.h"

HttpAndroidPremiumMemberShipTask::HttpAndroidPremiumMemberShipTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP;
}

HttpAndroidPremiumMemberShipTask::~HttpAndroidPremiumMemberShipTask() {
	// TODO Auto-generated destructor stub
}

void HttpAndroidPremiumMemberShipTask::SetCallback(IRequestAndroidPremiumMemberShipCallback* callback) {
	mpCallback = callback;
}

void HttpAndroidPremiumMemberShipTask::SetParam(

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAndroidPremiumMemberShipTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpAndroidPremiumMemberShipTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAndroidPremiumMemberShipTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    bool bParse = false;
    HttpAndroidProductItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
//        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
//        if (bParse) {
//            item.Parse(dataJson);
//        }

        
         bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if (bParse) {
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
        }
        
        //bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAndroidPremiumMemberShip(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

