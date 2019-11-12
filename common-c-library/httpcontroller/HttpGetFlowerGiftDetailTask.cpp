/*
 * HttpGetFlowerGiftDetailTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.2.获取鲜花礼品详情
 */

#include "HttpGetFlowerGiftDetailTask.h"

HttpGetFlowerGiftDetailTask::HttpGetFlowerGiftDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETGIFTDETAIL;
    
}

HttpGetFlowerGiftDetailTask::~HttpGetFlowerGiftDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetFlowerGiftDetailTask::SetCallback(IRequestGetFlowerGiftDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetFlowerGiftDetailTask::SetParam(
                                      const string& giftId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETGIFTDETAIL_GIFTID, giftId.c_str());

    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFlowerGiftDetailTask::SetParam( "
            "task : %p, "
            "giftId : %s"
            ")",
            this,
            giftId.c_str()
            );
}


bool HttpGetFlowerGiftDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFlowerGiftDetailTask::ParseData( "
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
    HttpFlowerGiftItem item;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETGIFTDETAIL_DETAIL].isObject()) {
                    item.Parse(dataJson[LIVEROOM_GETGIFTDETAIL_DETAIL]);
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
        mpCallback->OnGetFlowerGiftDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

