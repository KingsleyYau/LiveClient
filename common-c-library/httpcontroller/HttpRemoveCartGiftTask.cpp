/*
 * HttpRemoveCartGiftTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.10.删除购物车商品
 */

#include "HttpRemoveCartGiftTask.h"

HttpRemoveCartGiftTask::HttpRemoveCartGiftTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_REMOVECARTGIFT;
    
}

HttpRemoveCartGiftTask::~HttpRemoveCartGiftTask() {
	// TODO Auto-generated destructor stub
}

void HttpRemoveCartGiftTask::SetCallback(IRequestRemoveCartGiftCallback* callback) {
	mpCallback = callback;
}

void HttpRemoveCartGiftTask::SetParam(
                                   const string& anchorId,
                                   const string& giftId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_REMOVECARTGIFT_ANCHORID, anchorId.c_str());
    }
    
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_REMOVECARTGIFT_GIFTID, giftId.c_str());

    }
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRemoveCartGiftTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "giftId : %s "
            ")",
            this,
            anchorId.c_str(),
            giftId.c_str()
            );
}


bool HttpRemoveCartGiftTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRemoveCartGiftTask::ParseData( "
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
                if (dataJson[LIVEROOM_REMOVECARTGIFT_STATUS].isNumeric()) {
                    status = dataJson[LIVEROOM_REMOVECARTGIFT_STATUS].asInt();
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
        mpCallback->OnRemoveCartGift(this, bParse, errnum, errmsg, status);
    }
    
    return bParse;
}

