/*
 * HttpGetContactListTask.cpp
 *
 *  Created on: 2019-6-17
 *      Author: Alex
 *        desc: 3.16.获取我的联系人列表
 */

#include "HttpGetContactListTask.h"

HttpGetContactListTask::HttpGetContactListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCONTACTLIST;

}

HttpGetContactListTask::~HttpGetContactListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetContactListTask::SetCallback(IRequestGetContactListCallback* callback) {
	mpCallback = callback;
}

void HttpGetContactListTask::SetParam(
                                      int start,
                                      int step
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", start );
    mHttpEntiy.AddContent(LIVEROOM_GETCONTACTLIST_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step );
    mHttpEntiy.AddContent(LIVEROOM_GETCONTACTLIST_STEP, temp);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetContactListTask::SetParam( "
            "task : %p, "
            "start : %d,"
            "step : %d"
            ")",
            this,
            start,
            step
            );
}


bool HttpGetContactListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetContactListTask::ParseData( "
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
    RecommendAnchorList itemList;
    int totalCount = 0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].size(); i++) {
                        HttpRecommendAnchorItem item;
                        item.ParseContact(dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
                }
                if (dataJson[LIVEROOM_GETCONTACTLIST_TOTALCOUNT].isNumeric()) {
                    totalCount = dataJson[LIVEROOM_GETCONTACTLIST_TOTALCOUNT].asInt();
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
        mpCallback->OnGetContactList(this, bParse, errnum, errmsg, itemList, totalCount);
    }
    
    return bParse;
}

