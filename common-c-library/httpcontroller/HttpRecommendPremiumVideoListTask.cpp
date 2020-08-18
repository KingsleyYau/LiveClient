/*
 * HttpRecommendPremiumVideoListTask.cpp
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.11.获取可能感兴趣的推荐视频列表
 */

#include "HttpRecommendPremiumVideoListTask.h"

HttpRecommendPremiumVideoListTask::HttpRecommendPremiumVideoListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_MAYBEINTERESTEDLIST_PATH;

}

HttpRecommendPremiumVideoListTask::~HttpRecommendPremiumVideoListTask() {
	// TODO Auto-generated destructor stub
}

void HttpRecommendPremiumVideoListTask::SetCallback(IRequestRecommendPremiumVideoListCallback* callback) {
	mpCallback = callback;
}

void HttpRecommendPremiumVideoListTask::SetParam(
                                           int num
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    snprintf(temp, sizeof(temp), "%d", num);
    mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_NUM, temp);
    mNum = num;
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRecommendPremiumVideoListTask::SetParam( "
            "task : %p, "
            "num : %d "
            ")",
            this,
            num
            );
}

bool HttpRecommendPremiumVideoListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpRecommendPremiumVideoListTask::ParseData( "
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
    PremiumVideoBaseInfoList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
                
            if(dataJson.isArray()) {
                int i = 0;
                for (i = 0; i < dataJson.size(); i++) {
                    HttpPremiumVideoBaseInfoItem item;
                    item.Parse(dataJson.get(i, Json::Value::null));
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
        mpCallback->OnRecommendPremiumVideoList(this, bParse, errnum, errmsg, mNum, list);
    }
    
    return bParse;
}

