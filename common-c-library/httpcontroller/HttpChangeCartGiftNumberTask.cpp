/*
 * HttpChangeCartGiftNumberTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.9.修改购物车商品数量
 */

#include "HttpChangeCartGiftNumberTask.h"

HttpChangeCartGiftNumberTask::HttpChangeCartGiftNumberTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CHANGECARTGIFTNUMBER;
    
}

HttpChangeCartGiftNumberTask::~HttpChangeCartGiftNumberTask() {
	// TODO Auto-generated destructor stub
}

void HttpChangeCartGiftNumberTask::SetCallback(IRequestChangeCartGiftNumberCallback* callback) {
	mpCallback = callback;
}

void HttpChangeCartGiftNumberTask::SetParam(
                                            const string& anchorId,
                                            const string& giftId,
                                            int giftNumber
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_CHANGECARTGIFTNUMBER_ANCHORID, anchorId.c_str());
    }
    
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_CHANGECARTGIFTNUMBER_GIFTID, giftId.c_str());

    }
    
    snprintf(temp, sizeof(temp), "%d", giftNumber );
    mHttpEntiy.AddContent(LIVEROOM_CHANGECARTGIFTNUMBER_GIFTNUMBER, temp);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangeCartGiftNumberTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "giftId : %s, "
            "giftNumber : %d "
            ")",
            this,
            anchorId.c_str(),
            giftId.c_str(),
            giftNumber
            );
}


bool HttpChangeCartGiftNumberTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangeCartGiftNumberTask::ParseData( "
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
    int status = 0;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_CHANGECARTGIFTNUMBER_STATUS].isNumeric()) {
                    status = dataJson[LIVEROOM_CHANGECARTGIFTNUMBER_STATUS].asInt();
                }
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnChangeCartGiftNumber(this, bParse, errnum, errmsg, status);
    }
    
    return bParse;
}

