/*
 * HttpIOSPremiumMemberShipTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.6.获取产品列表（仅iOS）
 */

#include "HttpIOSPremiumMemberShipTask.h"

HttpIOSPremiumMemberShipTask::HttpIOSPremiumMemberShipTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_IOSPREMIUM_MEMBERSHIP;
}

HttpIOSPremiumMemberShipTask::~HttpIOSPremiumMemberShipTask() {
	// TODO Auto-generated destructor stub
}

void HttpIOSPremiumMemberShipTask::SetCallback(IRequestIOSPremiumMemberShipCallback* callback) {
	mpCallback = callback;
}

void HttpIOSPremiumMemberShipTask::SetParam(

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSPremiumMemberShipTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpIOSPremiumMemberShipTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpIOSPremiumMemberShipTask::ParseData( "
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
    HttpOrderProductItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if (bParse) {
            item.Parse(dataJson);
        }
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnIOSPremiumMemberShip(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

