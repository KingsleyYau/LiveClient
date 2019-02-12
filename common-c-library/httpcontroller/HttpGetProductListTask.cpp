/*
 * HttpGetProductListTask.cpp
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 10.4.标记私信已读
 */

#include "HttpGetProductListTask.h"

HttpGetProductListTask::HttpGetProductListTask() {
	// TODO Auto-generated constructor stub
	mPath = SETPRIVATEMESSAGEREADED_PATH;
    
    mToId = "";
    mMsgId = "";

}

HttpGetProductListTask::~HttpGetProductListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetProductListTask::SetCallback(IRequestGetProductListCallback* callback) {
	mpCallback = callback;
}

void HttpGetProductListTask::SetParam(
                                                const string& toId,
                                                const string& lastMsgId
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (toId.length() > 0) {
        mHttpEntiy.AddContent(SETPRIVATEMESSAGEREADED_TOID, toId.c_str());
        mToId = toId;
    }
    
    if (lastMsgId.length() > 0) {
        mHttpEntiy.AddContent(SETPRIVATEMESSAGEREADED_MSGID, lastMsgId.c_str());
        mMsgId = lastMsgId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetProductListTask::SetParam( "
            "task : %p, "
            "toId:%s,"
            "lastMsgId:%s,"
            ")",
            this,
            toId.c_str(),
            lastMsgId.c_str()
            );
}



bool HttpGetProductListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetProductListTask::ParseData( "
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
    bool result = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[SETPRIVATEMESSAGEREADED_RESULT].isNumeric()) {
                    result = dataJson[SETPRIVATEMESSAGEREADED_RESULT].asInt() == 0 ? false : true;
                }
            }
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetProductList(this, bParse, errnum, errmsg, result, mToId);
    }
    
    return bParse;
}

