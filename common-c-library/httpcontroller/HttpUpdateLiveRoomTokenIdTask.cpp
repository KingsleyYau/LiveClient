/*
 * HttpUpdateLiveRoomTokenIdTask.cpp
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 2.6.上传tokenid接口
 */

#include "HttpUpdateLiveRoomTokenIdTask.h"

HttpUpdateLiveRoomTokenIdTask::HttpUpdateLiveRoomTokenIdTask() {
	// TODO Auto-generated constructor stub
	mPath = UPDATE_TOKENID_PATH;
    mToken = "";
    mTokenId = "";
}

HttpUpdateLiveRoomTokenIdTask::~HttpUpdateLiveRoomTokenIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpUpdateLiveRoomTokenIdTask::SetCallback(IRequestUpdateLiveRoomTokenIdCallback* callback) {
	mpCallback = callback;
}

void HttpUpdateLiveRoomTokenIdTask::SetParam(
                                             string token,
                                             string tokenId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(UPDATE_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( tokenId.length() > 0 ) {
        mHttpEntiy.AddContent(UPDATE_TOKENID, tokenId.c_str());
        mTokenId = tokenId;
    }
    
    FileLog("httpcontroller",
            "HttpUpdateLiveRoomTokenIdTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "tokenId : %s, "
            ")",
            this,
            token.c_str(),
            tokenId.c_str()
            );
}

const string& HttpUpdateLiveRoomTokenIdTask::GetToken() {
    return mToken;
}

const string& HttpUpdateLiveRoomTokenIdTask::GetmTokenId() {
    return mTokenId;
}

bool HttpUpdateLiveRoomTokenIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpUpdateLiveRoomTokenIdTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpSetLiveRoomModifyInfoTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnUpdateLiveRoomTokenId(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

