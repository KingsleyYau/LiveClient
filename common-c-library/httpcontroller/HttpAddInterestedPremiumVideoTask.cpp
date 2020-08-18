/*
 * HttpAddInterestedPremiumVideoTask.cpp
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.10.添加收藏的视频
 */

#include "HttpAddInterestedPremiumVideoTask.h"

HttpAddInterestedPremiumVideoTask::HttpAddInterestedPremiumVideoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_ADDINTERESTED_PATH;
    mVideoId = "";

}

HttpAddInterestedPremiumVideoTask::~HttpAddInterestedPremiumVideoTask() {
	// TODO Auto-generated destructor stub
}

void HttpAddInterestedPremiumVideoTask::SetCallback(IRequestAddInterestedPremiumVideoCallback* callback) {
	mpCallback = callback;
}

void HttpAddInterestedPremiumVideoTask::SetParam(
                                           const string& videoId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (videoId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_VIDEO_ID, videoId.c_str());
        mVideoId = videoId;
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddInterestedPremiumVideoTask::SetParam( "
            "task : %p, "
            "videoId : %s "
            ")",
            this,
            videoId.c_str()
            );
}

bool HttpAddInterestedPremiumVideoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddInterestedPremiumVideoTask::ParseData( "
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
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAddInterestedPremiumVideo(this, bParse, errnum, errmsg, mVideoId);
    }
    
    return bParse;
}

