/*
 * ZBHttpUpdateTokenIdTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 2.2.上传tokenid接口
 */

#include "ZBHttpUpdateTokenIdTask.h"

ZBHttpUpdateTokenIdTask::ZBHttpUpdateTokenIdTask() {
	// TODO Auto-generated constructor stub
	mPath = UPDATETOKENID_PATH;
    mTokenId = "";
}

ZBHttpUpdateTokenIdTask::~ZBHttpUpdateTokenIdTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpUpdateTokenIdTask::SetCallback(IRequestZBUpdateTokenIdCallback* callback) {
	mpCallback = callback;
}

void ZBHttpUpdateTokenIdTask::SetParam(
                                    string tokenId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( tokenId.length() > 0 ) {
        mHttpEntiy.AddContent(UPDATETOKENID_TOKENID, tokenId.c_str());
        mTokenId = tokenId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpUpdateTokenIdTask::SetParam( "
            "task : %p, "
            "tokenId : %s, "
            ")",
            this,
            tokenId.c_str()
            );
}

const string& ZBHttpUpdateTokenIdTask::GetmTokenId() {
    return mTokenId;
}

bool ZBHttpUpdateTokenIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpUpdateTokenIdTask::ParseData( "
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
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBUpdateTokenId(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

