/*
 * HttpUnlockPremiumVideoTask.cpp
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *        desc: 18.14.视频解锁
 */

#include "HttpUnlockPremiumVideoTask.h"
#include "HttpRequestConvertEnum.h"

HttpUnlockPremiumVideoTask::HttpUnlockPremiumVideoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_UNLOCKVIDEO_PATH;
    mVideoId = "";

}

HttpUnlockPremiumVideoTask::~HttpUnlockPremiumVideoTask() {
	// TODO Auto-generated destructor stub
}

void HttpUnlockPremiumVideoTask::SetCallback(IRequestUnlockPremiumVideoCallback* callback) {
	mpCallback = callback;
}

void HttpUnlockPremiumVideoTask::SetParam(
                                            LSUnlockActionType type,
                                            const string& accessKey,
                                           const string& videoId
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    string strType = GetUnlockActionTypStr(type);
    if (strType.length()) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_ACTION, strType.c_str());
    }
    
    if (accessKey.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_ACCESS_KEY, accessKey.c_str());
    }
    
    if (videoId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUMVIDEO_VIDEO_ID, videoId.c_str());
        mVideoId = videoId;
    }


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUnlockPremiumVideoTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "typeStr : %s, "
            "accessKey : %s, "
            "videoId : %s "
            ")",
            this,
            type,
            strType.c_str(),
            accessKey.c_str(),
            videoId.c_str()
            );
}

bool HttpUnlockPremiumVideoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUnlockPremiumVideoTask::ParseData( "
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
    string videoUrlFull = "";
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].isString()) {
                    mVideoId = dataJson[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].asString();
                }
                if (dataJson[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_FULL].isString()) {
                    videoUrlFull = dataJson[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_FULL].asString();
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
        mpCallback->OnUnlockPremiumVideo(this, bParse, errnum, errmsg, mVideoId, videoUrlFull);
    }
    
    return bParse;
}

