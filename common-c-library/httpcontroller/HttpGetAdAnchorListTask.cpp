/*
 * HttpGetAdAnchorListTask.cpp
 *
 *  Created on: 2017-9-15
 *      Author: Alex
 *        desc: 6.4.获取QN广告列表
 */

#include "HttpGetAdAnchorListTask.h"

HttpGetAdAnchorListTask::HttpGetAdAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETADANCHORLIST;
    mNumber = 0;

}

HttpGetAdAnchorListTask::~HttpGetAdAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAdAnchorListTask::SetCallback(IRequestGetAdAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetAdAnchorListTask::SetParam(
                                            int number
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    snprintf(temp, sizeof(temp), "%d", mNumber);
    mHttpEntiy.AddContent(LIVEROOM_GETADANCHORLIST_NUMBER, temp);
    mNumber = number;

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAdAnchorListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

int HttpGetAdAnchorListTask::GetNumber(){
    return mNumber;
}


bool HttpGetAdAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAdAnchorListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetAdAnchorListTask::ParseData( buf : %s )", buf);
    }
    
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HotItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpLiveRoomInfoItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetAdAnchorList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}

