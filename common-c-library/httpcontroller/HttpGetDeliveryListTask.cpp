/*
 * HttpGetDeliveryListTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.5.获取My delivery列表
 */

#include "HttpGetDeliveryListTask.h"

HttpGetDeliveryListTask::HttpGetDeliveryListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETDELIVERYLIST;
    
}

HttpGetDeliveryListTask::~HttpGetDeliveryListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetDeliveryListTask::SetCallback(IRequestGetDeliveryListCallback* callback) {
	mpCallback = callback;
}

void HttpGetDeliveryListTask::SetParam(

                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetDeliveryListTask::SetParam( "
            "task : %p "
            ")",
            this
            );
}


bool HttpGetDeliveryListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetDeliveryListTask::ParseData( "
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
    DeliveryList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[LIVEROOM_GETDELIVERYLIST_LIST].isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson[LIVEROOM_GETDELIVERYLIST_LIST].size(); i++) {
                    HttpMyDeliveryItem item;
                    item.Parse(dataJson[LIVEROOM_GETDELIVERYLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetDeliveryList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

