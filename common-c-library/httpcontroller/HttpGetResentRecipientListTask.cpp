/*
 * HttpGetResentRecipientListTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.4.获取Resent Recipient主播列表
 */

#include "HttpGetResentRecipientListTask.h"

HttpGetResentRecipientListTask::HttpGetResentRecipientListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETRESENTRECIPIENTLIST;
    
}

HttpGetResentRecipientListTask::~HttpGetResentRecipientListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetResentRecipientListTask::SetCallback(IRequestGetResentRecipientListCallback* callback) {
	mpCallback = callback;
}

void HttpGetResentRecipientListTask::SetParam(

                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetResentRecipientListTask::SetParam( "
            "task : %p "
            ")",
            this
            );
}


bool HttpGetResentRecipientListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetResentRecipientListTask::ParseData( "
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
    RecipientAnchorList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson[LIVEROOM_GETRESENTRECIPIENTLIST_LIST].isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson[LIVEROOM_GETRESENTRECIPIENTLIST_LIST].size(); i++) {
                    HttpRecipientAnchorItem item;
                    item.Parse(dataJson[LIVEROOM_GETRESENTRECIPIENTLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetResentRecipientList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

