/*
 * HttpGetLiveRoomModifyInfoTask.cpp
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 4.2.获取可编辑的本人资料
 */

#include "HttpGetLiveRoomModifyInfoTask.h"


HttpGetLiveRoomModifyInfoTask::HttpGetLiveRoomModifyInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GET_MODIFY_INFO;
    mToken = "";
}

HttpGetLiveRoomModifyInfoTask::~HttpGetLiveRoomModifyInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomModifyInfoTask::SetCallback(IRequestGetLiveRoomModifyInfoCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomModifyInfoTask::SetParam(
                                            string token
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_TOKEN, token.c_str());
        mToken = token;
    }
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomModifyInfoTask::SetParam( "
            "task : %p, "
            "token : %s, "
            ")",
            this,
            token.c_str()
            );
}

const string& HttpGetLiveRoomModifyInfoTask::GetToken() {
    return mToken;
}



bool HttpGetLiveRoomModifyInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomModifyInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomModifyInfoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    HttpLiveRoomPersonalInfoItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            // 业务解析
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetLiveRoomModifyInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
