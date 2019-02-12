/*
 * HttpStartEditResumeTask.cpp
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 6.21.开始编辑简介触发计时
 */

#include "HttpStartEditResumeTask.h"

HttpStartEditResumeTask::HttpStartEditResumeTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_INTROEDIT;


}

HttpStartEditResumeTask::~HttpStartEditResumeTask() {
	// TODO Auto-generated destructor stub
}

void HttpStartEditResumeTask::SetCallback(IRequestStartEditResumeCallback* callback) {
	mpCallback = callback;
}

void HttpStartEditResumeTask::SetParam(
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);



    FileLog(LIVESHOW_HTTP_LOG,
            "HttpStartEditResumeTask::SetParam( "
            "task : %p"
            ")",
            this
            );
}



bool HttpStartEditResumeTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpStartEditResumeTask::ParseData( "
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

    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if( bParse) {

        }
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnStartEditResume(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

