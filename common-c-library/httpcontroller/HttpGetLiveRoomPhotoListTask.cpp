/*
 *  HttpGetLiveRoomPhotoListTask.cpp
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）
 */

#include "HttpGetLiveRoomPhotoListTask.h"

HttpGetLiveRoomPhotoListTask::HttpGetLiveRoomPhotoListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETPHOTOLIST;
    mToken = "";

}

HttpGetLiveRoomPhotoListTask::~HttpGetLiveRoomPhotoListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomPhotoListTask::SetCallback(IRequestGetLiveRoomPhotoListCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomPhotoListTask::SetParam(
                                         string token
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }

    
    FileLog("httpcontroller",
            "HttpGetLiveRoomPhotoListTask::SetParam( "
            "task : %p, "
            "token : %s, "
            ")",
            this,
            token.c_str()
            );
}

const string& HttpGetLiveRoomPhotoListTask::GetToken() {
    return mToken;
}


bool HttpGetLiveRoomPhotoListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomPhotoListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomPhotoListTask::ParseData( buf : %s )", buf);
    }
    
    CoverPhotoItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson[COMMON_LIST].isArray() ) {
                int i = 0;
                for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                    HttpLiveRoomCoverPhotoItem item;
                    item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                    itemList.push_back(item);
                }
            }

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetLiveRoomPhotoList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
