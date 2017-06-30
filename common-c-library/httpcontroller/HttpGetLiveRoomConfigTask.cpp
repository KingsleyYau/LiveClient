/*
 *  HttpGetLiveRoomConfigTask.cpp
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）
 */

#include "HttpGetLiveRoomConfigTask.h"

HttpGetLiveRoomConfigTask::HttpGetLiveRoomConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GET_CONFIG;

}

HttpGetLiveRoomConfigTask::~HttpGetLiveRoomConfigTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomConfigTask::SetCallback(IRequestGetLiveRoomConfigCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomConfigTask::SetParam(
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomConfigTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetLiveRoomConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomConfigTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomConfigTask::ParseData( buf : %s )", buf);
    }
    
    HttpLiveRoomConfigItem item;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson.isObject() ) {
                item.Parse(dataJson);
            }

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetLiveRoomConfig(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
