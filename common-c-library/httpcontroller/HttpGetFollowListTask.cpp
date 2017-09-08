/*
 * HttpGetFollowListTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.2.获取Following列表
 */

#include "HttpGetFollowListTask.h"


HttpGetFollowListTask::HttpGetFollowListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETFOLLOWLIST;
    mStart = 0;
    mStep = 0;
}

HttpGetFollowListTask::~HttpGetFollowListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetFollowListTask::SetCallback(IRequestGetFollowListCallback* callback) {
	mpCallback = callback;
}

void HttpGetFollowListTask::SetParam(
                                      int start,
                                      int step
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    char temp[16];
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_STEP, temp);
    mStep = step;
    
    
    FileLog("httpcontroller",
            "HttpGetFollowListTask::SetParam( "
            "task : %p, "
            "start : %d, "
            "step : %d, "
            ")",
            this,
            start,
            step
            );
}

int HttpGetFollowListTask::GetStart() {
    return mStart;
}

int HttpGetFollowListTask::GetStep() {
    return mStep;
}

bool HttpGetFollowListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetFollowListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetFollowListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    FollowItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpFollowItem item;
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
        mpCallback->OnGetFollowList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
