/*
 * HttpRideListTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.3.获取座驾列表
 */

#include "HttpRideListTask.h"

HttpRideListTask::HttpRideListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_RIDELIST;
}

HttpRideListTask::~HttpRideListTask() {
	// TODO Auto-generated destructor stub
}

void HttpRideListTask::SetCallback(IRequestRideListCallback* callback) {
	mpCallback = callback;
}

void HttpRideListTask::SetParam(
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRideListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpRideListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRideListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpRideListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    RideList list;
    int totalCount = 0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_RIDELIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_RIDELIST_LIST].size(); i++) {
                        HttpRideItem item;
                        item.Parse(dataJson[LIVEROOM_RIDELIST_LIST].get(i, Json::Value::null));
                        list.push_back(item);
                    }
                }
                
                if (dataJson[LIVEROOM_RIDELIST_TOTALCOUNT].isNumeric()) {
                    totalCount = dataJson[LIVEROOM_RIDELIST_TOTALCOUNT].asInt();
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
        mpCallback->OnRideList(this, bParse, errnum, errmsg, list, totalCount);
    }
    
    return bParse;
}

