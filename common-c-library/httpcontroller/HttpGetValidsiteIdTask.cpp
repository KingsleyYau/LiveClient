/*
 * HttpGetValidsiteIdTask.cpp
 *
 *  Created on: 2018-9-19
 *      Author: Alex
 *        desc: 2.13.可登录的站点列表
 */

#include "HttpGetValidsiteIdTask.h"

HttpGetValidsiteIdTask::HttpGetValidsiteIdTask() {
	// TODO Auto-generated constructor stub
	mPath = VALIDSITEID_PATH;
    
    mEmail = "";
    mPassword = "";

}

HttpGetValidsiteIdTask::~HttpGetValidsiteIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetValidsiteIdTask::SetCallback(IRequestGetValidsiteIdCallback* callback) {
	mpCallback = callback;
}

void HttpGetValidsiteIdTask::SetParam(
                                      const string& email,
                                      const string& password
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (email.length() > 0) {
        mHttpEntiy.AddContent(VALIDSITEID_EMAIL, email.c_str());
        mEmail = email;
    }
    
    if (password.length() > 0) {
        mHttpEntiy.AddContent(VALIDSITEID_PASSWORD, password.c_str());
        mPassword = password;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetValidsiteIdTask::SetParam( "
            "task : %p, "
            "email:%s,"
            "password:%s,"
            ")",
            this,
            email.c_str(),
            password.c_str()
            );
}



bool HttpGetValidsiteIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetValidsiteIdTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    bool bParse = false;
    HttpValidSiteIdList siteIdList;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if( bParse) {
            if (dataJson.isObject()) {
                if (dataJson[VALIDSITEID_DATALIST].isArray()) {
                    for (int i = 0; i < dataJson[VALIDSITEID_DATALIST].size(); i++) {
                        HttpValidSiteIdItem item;
                        item.Parse(dataJson[VALIDSITEID_DATALIST].get(i, Json::Value::null));
                        siteIdList.push_back(item);
                    }
                }
            }
        }
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetValidsiteId(this, bParse, errnum, errmsg, siteIdList);
    }
    
    return bParse;
}

