/*
 * HttpTokenLoginTask.cpp
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.21.token登录
 */

#include "HttpTokenLoginTask.h"
#include "HttpRequestConvertEnum.h"

HttpTokenLoginTask::HttpTokenLoginTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_AUTH_PATH;
}

HttpTokenLoginTask::~HttpTokenLoginTask() {
	// TODO Auto-generated destructor stub
}

void HttpTokenLoginTask::SetCallback(IRequestTokenLoginCallback* callback) {
	mpCallback = callback;
}

void HttpTokenLoginTask::SetParam(
                                  const string& memberId,
                                  const string& sid
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (memberId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_AUTH_MEMBERID, memberId.c_str());
    }
    
    if (sid.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_AUTH_SID, sid.c_str());
    }

    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpTokenLoginTask::SetParam( "
            "task : %p, "
            "memberId : %s"
            "sid : %s"
            ")",
            this,
            memberId.c_str(),
            sid.c_str()
            );
}

bool HttpTokenLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpTokenLoginTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    int errnum =LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    string memberId = "";
    string sid = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseNewLiveCommon(buf, size, errnum, errmsg, &dataJson);
        if(bParse) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_AUTH_USERSID].isString()) {
                   sid = dataJson[LIVEROOM_AUTH_USERSID].asString();
                }
                if (dataJson[LIVEROOM_AUTH_MANID].isString()) {
                    memberId = dataJson[LIVEROOM_AUTH_MANID].asString();
                }
            }
        }
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnTokenLogin(this, bParse, errnum, errmsg, memberId, sid);
    }
    
    return bParse;
}

