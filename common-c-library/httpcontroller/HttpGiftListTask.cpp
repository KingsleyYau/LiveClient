/*
 * HttpGiftListTask.cpp
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 5.1.获取背包礼物列表
 */

#include "HttpGiftListTask.h"

HttpGiftListTask::HttpGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_BACKPACK_GIFTLIST;
}

HttpGiftListTask::~HttpGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGiftListTask::SetCallback(IRequestGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGiftListTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog("httpcontroller",
            "HttpGiftListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGiftListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    BackGiftItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_BACKPACK_GIFT_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_BACKPACK_GIFT_LIST].size(); i++) {
                        HttpBackGiftItem item;
                        item.Parse(dataJson[LIVEROOM_BACKPACK_GIFT_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
                }
            }
            

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGiftList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}

