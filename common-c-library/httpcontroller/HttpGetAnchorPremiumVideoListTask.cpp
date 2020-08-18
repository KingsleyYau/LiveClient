/*
 * HttpGetAnchorPremiumVideoListTask.cpp
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.12.获取某主播的视频列表
 */

#include "HttpGetAnchorPremiumVideoListTask.h"

HttpGetAnchorPremiumVideoListTask::HttpGetAnchorPremiumVideoListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_ANCHORVIDEOLIST_PATH;

}

HttpGetAnchorPremiumVideoListTask::~HttpGetAnchorPremiumVideoListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAnchorPremiumVideoListTask::SetCallback(IRequestGetAnchorPremiumVideoListCallback* callback) {
	mpCallback = callback;
}

void HttpGetAnchorPremiumVideoListTask::SetParam(
                                           const string& anchorId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_ANCHOR_ID, anchorId.c_str());
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAnchorPremiumVideoListTask::SetParam( "
            "task : %p, "
            "anchorId : %s "
            ")",
            this,
            anchorId.c_str()
            );
}

bool HttpGetAnchorPremiumVideoListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAnchorPremiumVideoListTask::ParseData( "
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
            
            if (dataJson.isObject()) {
                
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
        mpCallback->OnGetAnchorPremiumVideoList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

