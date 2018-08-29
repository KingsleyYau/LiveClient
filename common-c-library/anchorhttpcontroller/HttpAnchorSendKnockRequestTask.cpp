/*
 * HttpAnchorSendKnockRequestTask.cpp
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.5.发起敲门请求
 */

#include "HttpAnchorSendKnockRequestTask.h"

HttpAnchorSendKnockRequestTask::HttpAnchorSendKnockRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = SENDKNOCKREQUEST_PATH;
    mRoomId = "";
}

HttpAnchorSendKnockRequestTask::~HttpAnchorSendKnockRequestTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorSendKnockRequestTask::SetCallback(IRequestAnchorSendKnockRequestCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorSendKnockRequestTask::SetParam(
                                                   const string& roomId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(SENDKNOCKREQUEST_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorSendKnockRequestTask::SetParam( "
            "task : %p, "
            "roomId : %s ,"
            ")",
            this,
            roomId.c_str()
            );
}

bool HttpAnchorSendKnockRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorSendKnockRequestTask::ParseData( "
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
    string knockId = "";
    int expire = 0;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[SENDKNOCKREQUEST_KNOCKID].isString()) {
                    knockId = dataJson[SENDKNOCKREQUEST_KNOCKID].asString();
                }
                
                if (dataJson[SENDKNOCKREQUEST_EXPIRE].isNumeric()) {
                    expire = dataJson[SENDKNOCKREQUEST_EXPIRE].asInt();
                }
                
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorSendKnockRequest(this, bParse, errnum, errmsg, knockId, expire);
    }
    
    return bParse;
}

