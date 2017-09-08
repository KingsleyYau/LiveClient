/*
 * HttpUpdateTokenIdTask.cpp
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 2.6.上传tokenid接口
 */

#include "HttpUpdateTokenIdTask.h"

HttpUpdateTokenIdTask::HttpUpdateTokenIdTask() {
	// TODO Auto-generated constructor stub
	mPath = UPDATE_TOKENID_PATH;
    mTokenId = "";
}

HttpUpdateTokenIdTask::~HttpUpdateTokenIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpUpdateTokenIdTask::SetCallback(IRequestUpdateTokenIdCallback* callback) {
	mpCallback = callback;
}

void HttpUpdateTokenIdTask::SetParam(
                                    string tokenId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( tokenId.length() > 0 ) {
        mHttpEntiy.AddContent(UPDATE_TOKENID, tokenId.c_str());
        mTokenId = tokenId;
    }
    
    FileLog("httpcontroller",
            "HttpUpdateTokenIdTask::SetParam( "
            "task : %p, "
            "tokenId : %s, "
            ")",
            this,
            tokenId.c_str()
            );
}

const string& HttpUpdateTokenIdTask::GetmTokenId() {
    return mTokenId;
}

bool HttpUpdateTokenIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpUpdateTokenIdTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpSetModifyInfoTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnUpdateTokenId(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

