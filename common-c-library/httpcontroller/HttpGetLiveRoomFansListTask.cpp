/*
 * HttpGetLiveRoomFansListTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.4.获取直播间观众头像列表（限定数量）
 */

#include "HttpGetLiveRoomFansListTask.h"


HttpGetLiveRoomFansListTask::HttpGetLiveRoomFansListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_FANSLIST;
    mToken = "";
    mRoomId = "";
}

HttpGetLiveRoomFansListTask::~HttpGetLiveRoomFansListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomFansListTask::SetCallback(IRequestGetLiveRoomFansListCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomFansListTask::SetParam(
                                     string token,
                                     string roomId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_ID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomFansListTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "roomId : %s, "
            ")",
            this,
            token.c_str(),
            roomId.c_str()
            );
}

const string& HttpGetLiveRoomFansListTask::GetToken() {
    return mToken;
}

const string& HttpGetLiveRoomFansListTask::GetRoomId() {
    return mRoomId;
}

bool HttpGetLiveRoomFansListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomFansListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomFansListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    ViewerItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson[COMMON_LIST].isArray()) {
                int i = 0;
                for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                    HttpLiveRoomViewerItem item;
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
        mpCallback->OnGetLiveRoomFansList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
