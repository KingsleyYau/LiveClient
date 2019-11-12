/*
 * HttpGetStoreGiftListTask.cpp
 *
 *  Created on: 2019-09-26
 *      Author: Alex
 *        desc: 15.1.获取鲜花礼品列表
 */

#include "HttpGetStoreGiftListTask.h"

HttpGetStoreGiftListTask::HttpGetStoreGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETSTOREGIFTLIST;
    
}

HttpGetStoreGiftListTask::~HttpGetStoreGiftListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetStoreGiftListTask::SetCallback(IRequestGetStoreGiftListCallback* callback) {
	mpCallback = callback;
}

void HttpGetStoreGiftListTask::SetParam(
                                      const string& anchorId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( anchorId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETSTOREGIFTLIST_ANCHORID, anchorId.c_str());

    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetStoreGiftListTask::SetParam( "
            "task : %p, "
            "anchorId : %s"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpGetStoreGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetStoreGiftListTask::ParseData( "
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
    StoreFlowerGiftList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[LIVEROOM_GETSTOREGIFTLIST_LIST].isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson[LIVEROOM_GETSTOREGIFTLIST_LIST].size(); i++) {
                    HttpStoreFlowerGiftItem item;
                    item.Parse(dataJson[LIVEROOM_GETSTOREGIFTLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetStoreGiftList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

