/*
 * HttpAddCartGiftTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.8.添加购物车商品
 */

#include "HttpAddCartGiftTask.h"

HttpAddCartGiftTask::HttpAddCartGiftTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ADDCARTGIFT;
    
}

HttpAddCartGiftTask::~HttpAddCartGiftTask() {
	// TODO Auto-generated destructor stub
}

void HttpAddCartGiftTask::SetCallback(IRequestAddCartGiftCallback* callback) {
	mpCallback = callback;
}

void HttpAddCartGiftTask::SetParam(
                                   const string& anchorId,
                                   const string& giftId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ADDCARTGIFT_ANCHORID, anchorId.c_str());
    }
    
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ADDCARTGIFT_GIFTID, giftId.c_str());

    }
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddCartGiftTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "giftId : %s "
            ")",
            this,
            anchorId.c_str(),
            giftId.c_str()
            );
}


bool HttpAddCartGiftTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddCartGiftTask::ParseData( "
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
                if (dataJson[LIVEROOM_ADDCARTGIFT_STATUS].isNumeric()) {
                    status = dataJson[LIVEROOM_ADDCARTGIFT_STATUS].asInt();
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
        mpCallback->OnAddCartGift(this, bParse, errnum, errmsg, status);
    }
    
    return bParse;
}

