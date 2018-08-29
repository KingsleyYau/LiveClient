/*
 * HttpChangeFavouriteTask.cpp
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.4.关注/取消关注节目
 */

#include "HttpChangeFavouriteTask.h"

HttpChangeFavouriteTask::HttpChangeFavouriteTask() {
	// TODO Auto-generated constructor stub
	mPath = CHANGEFAVOURITE_PATH;
    mLiveShowId = "";
    mIsCancel = false;
}

HttpChangeFavouriteTask::~HttpChangeFavouriteTask() {
	// TODO Auto-generated destructor stub
}

void HttpChangeFavouriteTask::SetCallback(IRequestChangeFavouriteCallback* callback) {
	mpCallback = callback;
}

void HttpChangeFavouriteTask::SetParam(
                                               const string& liveShowId,
                                               bool isCancel
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    if (liveShowId.length() > 0) {
        mHttpEntiy.AddContent(CHANGEFAVOURITE_LIVESHOWID, liveShowId.c_str());
        mLiveShowId = liveShowId;
    }
    
    snprintf(temp, sizeof(temp), "%d", isCancel == true ? 1 : 0);
    mHttpEntiy.AddContent(CHANGEFAVOURITE_CANCEL, temp);
    mIsCancel = isCancel;

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangeFavouriteTask::SetParam( "
            "task : %p, "
            "liveShowId : %s ,"
            "isCancel :%d"
            ")",
            this,
            liveShowId.c_str(),
            isCancel
            );
}

bool HttpChangeFavouriteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpChangeFavouriteTask::ParseData( "
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
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnFollowShow(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

