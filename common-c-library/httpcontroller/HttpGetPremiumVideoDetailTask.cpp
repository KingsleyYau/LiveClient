/*
 * HttpGetPremiumVideoDetailTask.cpp
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.13.获取视频详情
 */

#include "HttpGetPremiumVideoDetailTask.h"

HttpGetPremiumVideoDetailTask::HttpGetPremiumVideoDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_GETVIDEODETAIL_PATH;

}

HttpGetPremiumVideoDetailTask::~HttpGetPremiumVideoDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPremiumVideoDetailTask::SetCallback(IRequestGetPremiumVideoDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetPremiumVideoDetailTask::SetParam(
                                           const string& videoId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (videoId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_VIDEO_ID, videoId.c_str());
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoDetailTask::SetParam( "
            "task : %p, "
            "videoId : %s "
            ")",
            this,
            videoId.c_str()
            );
}

bool HttpGetPremiumVideoDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoDetailTask::ParseData( "
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
    HttpPremiumVideoDetailItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if (dataJson.isObject()) {
                item.Parse(dataJson);
            }
            
            
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetPremiumVideoDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

