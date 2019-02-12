/*
 * HttpPasswordLoginTask.cpp
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.20.帐号密码登录
 */

#include "HttpPasswordLoginTask.h"
#include "HttpRequestConvertEnum.h"

HttpPasswordLoginTask::HttpPasswordLoginTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PASSWORDLOGIN_PATH;
}

HttpPasswordLoginTask::~HttpPasswordLoginTask() {
	// TODO Auto-generated destructor stub
}

void HttpPasswordLoginTask::SetCallback(IRequestPasswordLoginCallback* callback) {
	mpCallback = callback;
}

void HttpPasswordLoginTask::SetParam(
                                     const string& email,
                                     const string& password,
                                     const string& authcode,
                                     HTTP_OTHER_SITE_TYPE siteId,
                                     const string& afDeviceId,
                                     const string& gaid,
                                     const string& deviceId
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (email.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_EMAIL, email.c_str());
    }
    
    if (password.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_PASSWORD, password.c_str());
    }
    
    if (authcode.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_AUTHCODE, authcode.c_str());
    }
    
    if (afDeviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_AF_DEVICEID, afDeviceId.c_str());
    }
    
    if (gaid.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_GAID, gaid.c_str());
    }
    
    if (deviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_DEVICEID, deviceId.c_str());
    }
    
    // siteid
    string strSite("");
    strSite = GetHttpSiteId(siteId);
    mHttpEntiy.AddContent(LIVEROOM_PASSWORDLOGIN_SOURCE, strSite);

    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPasswordLoginTask::SetParam( "
            "task : %p, "
            "email : %s"
            "password : %s"
            "password : %s"
            "siteId : %d"
            "afDeviceId : %s"
            "gaid : %s"
            "deviceId : %s"
            ")",
            this,
            email.c_str(),
            password.c_str(),
            password.c_str(),
            siteId,
            afDeviceId.c_str(),
            gaid.c_str(),
            deviceId.c_str()
            );
}

bool HttpPasswordLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPasswordLoginTask::ParseData( "
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
    string memberId = "";
    string sid = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseNewLiveCommon(buf, size, errnum, errmsg, &dataJson);
        if(bParse) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_PASSWORDLOGIN_MANID].isString()) {
                    memberId = dataJson[LIVEROOM_PASSWORDLOGIN_MANID].asString();
                }
                if (dataJson[LIVEROOM_PASSWORDLOGIN_USERSID].isString()) {
                    sid = dataJson[LIVEROOM_PASSWORDLOGIN_USERSID].asString();
                }
            }
        }
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnPasswordLogin(this, bParse, errnum, errmsg, memberId, sid);
    }
    
    return bParse;
}

