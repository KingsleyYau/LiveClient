/*
 * HttpAddAnchorFriendTask.cpp
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *        desc: 6.9.请求添加好友
 */

#include "HttpAddAnchorFriendTask.h"

HttpAddAnchorFriendTask::HttpAddAnchorFriendTask() {
	// TODO Auto-generated constructor stub
	mPath = HANGOUTADDANCHORFRIEND_PATH;
    mUserId = "";
}

HttpAddAnchorFriendTask::~HttpAddAnchorFriendTask() {
	// TODO Auto-generated destructor stub
}

void HttpAddAnchorFriendTask::SetCallback(IRequestAddAnchorFriendCallback* callback) {
	mpCallback = callback;
}

void HttpAddAnchorFriendTask::SetParam(
                                       const string& userId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (userId.length() > 0) {
        mHttpEntiy.AddContent(HANGOUTADDANCHORFRIEND_USERID, userId.c_str());
        mUserId = userId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddAnchorFriendTask::SetParam( "
            "task : %p, "
            "userId : %s ,"
            ")",
            this,
            userId.c_str()
            );
}

bool HttpAddAnchorFriendTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAddAnchorFriendTask::ParseData( "
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
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAddAnchorFriend(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

