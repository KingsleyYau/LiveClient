/*
 * HttpGetMyProfileTask.cpp
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 6.18.查询个人信息
 */

#include "HttpGetMyProfileTask.h"

HttpGetMyProfileTask::HttpGetMyProfileTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_MYPROFILE;


}

HttpGetMyProfileTask::~HttpGetMyProfileTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetMyProfileTask::SetCallback(IRequestGetMyProfileCallback* callback) {
	mpCallback = callback;
}

void HttpGetMyProfileTask::SetParam(
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetMyProfileTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}



bool HttpGetMyProfileTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetMyProfileTask::ParseData( "
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
    HttpProfileItem profileItem;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if(bParse) {
            if (dataJson.isObject()) {
                profileItem.Parse(dataJson);
            }
        }
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetMyProfile(this, bParse, errnum, errmsg, profileItem);
    }
    
    return bParse;
}

