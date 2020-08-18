/*
 * HttpDeletePremiumVideoRecentlyWatchedTask.cpp
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *        desc: 18.7.删除最近播放的视频
 */

#include "HttpDeletePremiumVideoRecentlyWatchedTask.h"

HttpDeletePremiumVideoRecentlyWatchedTask::HttpDeletePremiumVideoRecentlyWatchedTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_DELETERECENTLYWATCHED_PATH;
    mWatchedId = "";

}

HttpDeletePremiumVideoRecentlyWatchedTask::~HttpDeletePremiumVideoRecentlyWatchedTask() {
	// TODO Auto-generated destructor stub
}

void HttpDeletePremiumVideoRecentlyWatchedTask::SetCallback(IRequestDeletePremiumVideoRecentlyWatchedCallback* callback) {
	mpCallback = callback;
}

void HttpDeletePremiumVideoRecentlyWatchedTask::SetParam(
                                           const string& watchedId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (watchedId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_ID, watchedId.c_str());
        mWatchedId = watchedId;
    }
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDeletePremiumVideoRecentlyWatchedTask::SetParam( "
            "task : %p, "
            "watchedId : %s "
            ")",
            this,
            watchedId.c_str()
            );
}

bool HttpDeletePremiumVideoRecentlyWatchedTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpDeletePremiumVideoRecentlyWatchedTask::ParseData( "
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
        mpCallback->OnDeletePremiumVideoRecentlyWatched(this, bParse, errnum, errmsg, mWatchedId);
    }
    
    return bParse;
}

