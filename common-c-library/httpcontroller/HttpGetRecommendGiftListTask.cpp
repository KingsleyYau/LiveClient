/*
 * HttpGetRecommendGiftListTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.3.获取推荐鲜花礼品列表
 */

#include "HttpGetRecommendGiftListTask.h"

HttpGetRecommendGiftListTask::HttpGetRecommendGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETRECOMMENDGIFTLIST;
    
}

HttpGetRecommendGiftListTask::~HttpGetRecommendGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetRecommendGiftListTask::SetCallback(IRequestGetRecommendGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetRecommendGiftListTask::SetParam(
                                            const string& giftId,
                                            const string& anchorId,
                                            int number
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETRECOMMENDGIFTLIST_GIFTID, giftId.c_str());

    }
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETRECOMMENDGIFTLIST_ANCHORID, anchorId.c_str());
    }
    
    snprintf(temp, sizeof(temp), "%d", number );
    mHttpEntiy.AddContent(LIVEROOM_GETRECOMMENDGIFTLIST_NUMBER, temp);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetRecommendGiftListTask::SetParam( "
            "task : %p, "
            "giftId : %s, "
            "anchorId : %s, "
            "number : %d "
            ")",
            this,
            giftId.c_str(),
            anchorId.c_str(),
            number
            );
}


bool HttpGetRecommendGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetRecommendGiftListTask::ParseData( "
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
    FlowerGiftList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[LIVEROOM_GETRECOMMENDGIFTLIST_LIST].isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson[LIVEROOM_GETRECOMMENDGIFTLIST_LIST].size(); i++) {
                    HttpFlowerGiftItem item;
                    item.Parse(dataJson[LIVEROOM_GETRECOMMENDGIFTLIST_LIST].get(i, Json::Value::null));
                    list.push_back(item);
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
        mpCallback->OnGetRecommendGiftList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

