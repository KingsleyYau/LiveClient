/*
 * HttpGetInterestedPremiumVideoListTask.cpp
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.8.获取收藏的视频列表
 */

#include "HttpGetInterestedPremiumVideoListTask.h"

HttpGetInterestedPremiumVideoListTask::HttpGetInterestedPremiumVideoListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_INTERESTEDLIST_PATH;

}

HttpGetInterestedPremiumVideoListTask::~HttpGetInterestedPremiumVideoListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetInterestedPremiumVideoListTask::SetCallback(IRequestGetInterestedPremiumVideoListCallback* callback) {
	mpCallback = callback;
}

void HttpGetInterestedPremiumVideoListTask::SetParam(
                                           int start,
                                           int step
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_STEP, temp);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetInterestedPremiumVideoListTask::SetParam( "
            "task : %p, "
            "start : %d, "
            "step : %d "
            ")",
            this,
            start,
            step
            );
}

bool HttpGetInterestedPremiumVideoListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetInterestedPremiumVideoListTask::ParseData( "
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
    int totalCount = 0;
    PremiumVideoBaseInfoList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_PREMIUMVIDEO_TOTAL_COUNT].isNumeric()) {
                    totalCount = dataJson[LIVEROOM_PREMIUMVIDEO_TOTAL_COUNT].asInt();
                }
                
                if(dataJson[LIVEROOM_PREMIUMVIDEO_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_PREMIUMVIDEO_LIST].size(); i++) {
                        HttpPremiumVideoBaseInfoItem item;
                        item.Parse(dataJson[LIVEROOM_PREMIUMVIDEO_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetInterestedPremiumVideoList(this, bParse, errnum, errmsg, totalCount, list);
    }
    
    return bParse;
}

