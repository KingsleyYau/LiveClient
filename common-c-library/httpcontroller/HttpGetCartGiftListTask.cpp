/*
 * HttpGetCartGiftListTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.7.获取购物车My cart列表
 */

#include "HttpGetCartGiftListTask.h"

HttpGetCartGiftListTask::HttpGetCartGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCARTGIFTLIST;
    
}

HttpGetCartGiftListTask::~HttpGetCartGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCartGiftListTask::SetCallback(IRequestGetCartGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetCartGiftListTask::SetParam(
                                       int start,
                                       int step
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", start );
    mHttpEntiy.AddContent(LIVEROOM_GETCARTGIFTLIST_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step );
    mHttpEntiy.AddContent(LIVEROOM_GETCARTGIFTLIST_STEP, temp);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCartGiftListTask::SetParam( "
            "task : %p, "
            "start : %s, "
            "step : %d "
            ")",
            this,
            start,
            step
            );
}


bool HttpGetCartGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCartGiftListTask::ParseData( "
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
    int total = 0;
    MyCartItemList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETCARTGIFTLIST_TOTAL].isNumeric()) {
                    total = dataJson[LIVEROOM_GETCARTGIFTLIST_TOTAL].asInt();
                }
                
                if (dataJson[LIVEROOM_GETCARTGIFTLIST_LIST].isArray()) {
                    int i = 0;
                    for ( i = 0; i < dataJson[LIVEROOM_GETCARTGIFTLIST_LIST].size(); i++) {
                        HttpMyCartItem item;
                        item.Parse(dataJson[LIVEROOM_GETCARTGIFTLIST_LIST].get(i, Json::Value::null));
                        list.push_back(item);
                    }
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
        mpCallback->OnGetCartGiftList(this, bParse, errnum, errmsg, total, list);
    }
    
    return bParse;
}

