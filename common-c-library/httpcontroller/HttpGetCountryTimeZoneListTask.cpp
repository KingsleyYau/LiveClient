/*
 *HttpGetCountryTimeZoneListTask.cpp
 *
 *  Created on: 2020-3-18
 *      Author: Alex
 *        desc: 17.2.获取国家时区列表
 */

#include "HttpGetCountryTimeZoneListTask.h"

HttpGetCountryTimeZoneListTask::HttpGetCountryTimeZoneListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCOUNTRYTIMEZONELIST;
}

HttpGetCountryTimeZoneListTask::~HttpGetCountryTimeZoneListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCountryTimeZoneListTask::SetCallback(IRequestGetCountryTimeZoneListCallback* callback) {
	mpCallback = callback;
}

void HttpGetCountryTimeZoneListTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCountryTimeZoneListTask::SetParam( "
            "task : %p"
            ")",
            this
            );
}

bool HttpGetCountryTimeZoneListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCountryTimeZoneListTask::ParseData( "
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
    CountryTimeZoneList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isArray()) {
                for (int i = 0; i < dataJson.size(); i++) {
                    Json::Value element = dataJson.get(i, Json::Value::null);
                    HttpCountryTimeZoneItem item;
                    if (item.Parse(element)) {
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
        mpCallback->OnGetCountryTimeZoneList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

