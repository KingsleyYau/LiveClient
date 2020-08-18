/*
 * HttpGetPremiumVideoKeyRequestListTask.cpp
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.3.获取解码锁请求列表
 */

#include "HttpGetPremiumVideoKeyRequestListTask.h"

HttpGetPremiumVideoKeyRequestListTask::HttpGetPremiumVideoKeyRequestListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_ACCESSKEYREQUESTLIST_PATH;

}

HttpGetPremiumVideoKeyRequestListTask::~HttpGetPremiumVideoKeyRequestListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPremiumVideoKeyRequestListTask::SetCallback(IRequestGetPremiumVideoKeyRequestListCallback* callback) {
	mpCallback = callback;
}

void HttpGetPremiumVideoKeyRequestListTask::SetParam(
                                           LSAccessKeyType type,
                                           int start,
                                           int step
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (type > LSACCESSKEYTYPE_BEGIN && type <= LSACCESSKEYTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", GetLSAccessKeyTypeToInt(type));
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_TYPE, temp);
    }
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_STEP, temp);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoKeyRequestListTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "start : %d, "
            "step : %d "
            ")",
            this,
            type,
            start,
            step
            );
}

bool HttpGetPremiumVideoKeyRequestListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoKeyRequestListTask::ParseData( "
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
    PremiumVideoAccessKeyList list;
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
                        HttpPremiumVideoAccessKeyItem item;
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
        mpCallback->OnGetPremiumVideoKeyRequestList(this, bParse, errnum, errmsg, totalCount, list);
    }
    
    return bParse;
}

