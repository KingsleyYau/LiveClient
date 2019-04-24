/*
 * HttpGetSayHiAnchorListTask.cpp
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.2.符合发送Say Hi的主播列表
 */

#include "HttpGetSayHiAnchorListTask.h"

HttpGetSayHiAnchorListTask::HttpGetSayHiAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETSAYHIANCHORLIST;

}

HttpGetSayHiAnchorListTask::~HttpGetSayHiAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetSayHiAnchorListTask::SetCallback(IRequestGetSayHiAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetSayHiAnchorListTask::SetParam(
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSayHiAnchorListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetSayHiAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSayHiAnchorListTask::ParseData( "
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
    HttpSayHiAnchorList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GETSAYHIANCHORLIST_LIST].isArray()) {
                    for (int i = 0; i < dataJson[LIVEROOM_GETSAYHIANCHORLIST_LIST].size(); i++) {
                        Json::Value element = dataJson[LIVEROOM_GETSAYHIANCHORLIST_LIST].get(i, Json::Value::null);
                        HttpSayHiAnchorItem item;
                        if (item.Parse(element)) {
                            list.push_back(item);
                        }
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
        mpCallback->OnGetSayHiAnchorList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

