/*
 *  HttpGetAllGiftListTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
 */

#include "HttpGetAllGiftListTask.h"

HttpGetAllGiftListTask::HttpGetAllGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETALLGIFTLIST;

}

HttpGetAllGiftListTask::~HttpGetAllGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAllGiftListTask::SetCallback(IRequestGetAllGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetAllGiftListTask::SetParam(
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAllGiftListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetAllGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAllGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetAllGiftListTask::ParseData( buf : %s )", buf);
    }
    
    GiftItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GIFT_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_GIFT_LIST].size(); i++) {
                        HttpGiftInfoItem item;
                        item.Parse(dataJson[LIVEROOM_GIFT_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetAllGiftList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
