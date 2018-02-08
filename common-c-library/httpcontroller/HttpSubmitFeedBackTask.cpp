/*
 * HttpSubmitFeedBackTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.13.提交Feedback（仅独立）
 */

#include "HttpSubmitFeedBackTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpSubmitFeedBackTask::HttpSubmitFeedBackTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_SUBMITFEEDBACK;
    mMail = "";
    mMsg = "";
   
}

HttpSubmitFeedBackTask::~HttpSubmitFeedBackTask() {
    // TODO Auto-generated destructor stub
}

void HttpSubmitFeedBackTask::SetCallback(IRequestSubmitFeedBackCallback* callback) {
    mpCallback = callback;
}

void HttpSubmitFeedBackTask::SetParam(
                                      string mail,
                                      string msg
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( mail.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITFEEDBACK_MAIL, mail.c_str());
        mMail = mail;
    }
    
    if( msg.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_SUBMITFEEDBACK_MSG, msg.c_str());
        mMsg = msg;
    }
    
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpSubmitFeedBackTask::SetParam( "
            "task : %p, "
            "mail : %s "
            "msg : %s "
            ")",
            this,
            mail.c_str(),
            msg.c_str()
            );
}


bool HttpSubmitFeedBackTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSubmitFeedBackTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpSubmitFeedBackTask::ParseData( buf : %s )", buf);
    }
    
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
        mpCallback->OnSubmitFeedBack(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
