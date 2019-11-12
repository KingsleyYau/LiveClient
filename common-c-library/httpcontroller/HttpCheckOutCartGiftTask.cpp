/*
 * HttpCheckOutCartGiftTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.11.Checkout商品
 */

#include "HttpCheckOutCartGiftTask.h"

HttpCheckOutCartGiftTask::HttpCheckOutCartGiftTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CHECKOUT;
    
}

HttpCheckOutCartGiftTask::~HttpCheckOutCartGiftTask() {
	// TODO Auto-generated destructor stub
}

void HttpCheckOutCartGiftTask::SetCallback(IRequestCheckOutCartGiftCallback* callback) {
	mpCallback = callback;
}

void HttpCheckOutCartGiftTask::SetParam(
                                   const string& anchorId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_CHECKOUT_ANCHORID, anchorId.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCheckOutCartGiftTask::SetParam( "
            "task : %p, "
            "anchorId : %s "
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpCheckOutCartGiftTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCheckOutCartGiftTask::ParseData( "
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
    bool bParse = false;
    HttpCheckoutItem item;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnCheckOutCartGift(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

