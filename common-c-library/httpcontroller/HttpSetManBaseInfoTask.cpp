/*
 * HttpSetManBaseInfoTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.15.设置个人信息（仅独立）
 */

#include "HttpSetManBaseInfoTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpSetManBaseInfoTask::HttpSetManBaseInfoTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_SETMANBASEINFO;
    mNickName = "";
   
}

HttpSetManBaseInfoTask::~HttpSetManBaseInfoTask() {
    // TODO Auto-generated destructor stub
}

void HttpSetManBaseInfoTask::SetCallback(IRequestSetManBaseInfoCallback* callback) {
    mpCallback = callback;
}

void HttpSetManBaseInfoTask::SetParam(
                                      string nickName
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( nickName.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SETMANBASEINFO_NICKNAME, nickName.c_str());
        mNickName = nickName;
    }

    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetManBaseInfoTask::SetParam( "
            "task : %p, "
            "nickName : %s "
            ")",
            this,
            nickName.c_str()
            );
}


bool HttpSetManBaseInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSetManBaseInfoTask::ParseData( "
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
        mpCallback->OnSetManBaseInfo(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
