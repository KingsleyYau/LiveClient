/*
 * HttpLogoutTask.cpp
 *
 *  Created on: 2017-5-18
 *      Author: Alex
 *        desc: 2.5.注销 
 */

#include "HttpLogoutTask.h"

HttpLogoutTask::HttpLogoutTask() {
	// TODO Auto-generated constructor stub
	mPath = LOGOUT_PATH;
	mToken = "";
}

HttpLogoutTask::~HttpLogoutTask() {
	// TODO Auto-generated destructor stub
}

void HttpLogoutTask::SetCallback(IRequestLogoutCallback* callback) {
	mpCallback = callback;
}

void HttpLogoutTask::SetParam(
		string token
		) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

	if( token.length() > 0 ) {
		mHttpEntiy.AddContent(LOGOUT_TOKEN, token.c_str());
		mToken = token;
	}


	FileLog("httpcontroller",
            "HttpLogoutTask::SetParam( "
            "task : %p, "
			"tokenId : %s, "
			")",
            this,
			token.c_str()
            );
}

const string& HttpLogoutTask::GetToken() {
	return mToken;
}

bool HttpLogoutTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpLogoutTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpLogoutTask::ParseData( buf : %s )", buf);
    }
    
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
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnLogout(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
