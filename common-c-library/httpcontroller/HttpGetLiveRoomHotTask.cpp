/*
 * HttpGetLiveRoomHotTask.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 3.6.获取Hot列表
 */

#include "HttpGetLiveRoomHotTask.h"


HttpGetLiveRoomHotTask::HttpGetLiveRoomHotTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_HOT;
    mToken = "";
    mStart = 0;
    mStep = 0;
}

HttpGetLiveRoomHotTask::~HttpGetLiveRoomHotTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomHotTask::SetCallback(IRequestGetLiveRoomHotCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomHotTask::SetParam(
                                      string token,
                                      int start,
                                      int step
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_STEP, temp);
    mStep = step;
    
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomHotTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "start : %d, "
            "step : %d, "
            ")",
            this,
            token.c_str(),
            start,
            step
            );
}

const string& HttpGetLiveRoomHotTask::GetToken() {
    return mToken;
}

int HttpGetLiveRoomHotTask::GetStart() {
    return mStart;
}

int HttpGetLiveRoomHotTask::GetStep() {
    return mStep;
}

bool HttpGetLiveRoomHotTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomHotTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomHotTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HotItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson[COMMON_LIST].isArray()) {
                int i = 0;
                for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                    HttpLiveRoomInfoItem item;
                    item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                    itemList.push_back(item);
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
        mpCallback->OnGetLiveRoomHot(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
