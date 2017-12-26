/*
 * HttpGetManBaseInfoTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.14.获取个人信息（仅独立）
 */

#include "HttpGetManBaseInfoTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpGetManBaseInfoTask::HttpGetManBaseInfoTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_GETMANBASEINFO;
   
}

HttpGetManBaseInfoTask::~HttpGetManBaseInfoTask() {
    // TODO Auto-generated destructor stub
}

void HttpGetManBaseInfoTask::SetCallback(IRequestGetManBaseInfoCallback* callback) {
    mpCallback = callback;
}

void HttpGetManBaseInfoTask::SetParam(

                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetManBaseInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetManBaseInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetManBaseInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetManBaseInfoTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpManBaseInfoItem item;
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        // LSalextest
        if (bParse == false) {
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
            bParse = true;
            item.userId = "alexuserId";
            item.nickName = "alex";
            item.nickNameStatus = NICKNAMEVERIFYSTATUS_HANDLDING;
            item.photoUrl = "1235";
            item.photoStatus = PHOTOVERIFYSTATUS_HANDLDING;
            item.birthday = "19870201";
            item.userlevel = 0;
        }
        
    } else {
//        // 超时
//        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
//        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
        // LSalextest
        errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
        errmsg = "";
        bParse = true;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetManBaseInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
