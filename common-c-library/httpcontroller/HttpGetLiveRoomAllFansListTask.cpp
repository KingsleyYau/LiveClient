/*
 * HttpGetLiveRoomAllFansListTask.cpp
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 3.5.获取直播间所有观众头像列表
 */

#include "HttpGetLiveRoomAllFansListTask.h"


HttpGetLiveRoomAllFansListTask::HttpGetLiveRoomAllFansListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_MORE_FANSLIST;
    mToken = "";
    mRoomId = "";
    mStart = 0;
    mStep = 0;
}

HttpGetLiveRoomAllFansListTask::~HttpGetLiveRoomAllFansListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveRoomAllFansListTask::SetCallback(IRequestGetLiveRoomAllFansListCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveRoomAllFansListTask::SetParam(
                                              string token,
                                              string roomId,
                                              int start,
                                              int step
                                     ) {

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

    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_STEP, temp);
    mStep = step;
    
    
    FileLog("httpcontroller",
            "HttpGetLiveRoomAllFansListTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "roomId : %s, "
            "start : %d, "
            "step : %d, "
            ")",
            this,
            token.c_str(),
            roomId.c_str(),
            start,
            step
            );
}

const string& HttpGetLiveRoomAllFansListTask::GetToken() {
    return mToken;
}

const string& HttpGetLiveRoomAllFansListTask::GetRoomId() {
    return mRoomId;
}

int HttpGetLiveRoomAllFansListTask::GetStart() {
    return mStart;
}

int HttpGetLiveRoomAllFansListTask::GetStep() {
    return mStep;
}

bool HttpGetLiveRoomAllFansListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetLiveRoomAllFansListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetLiveRoomAllFansListTask::ParseData( buf : %s )", buf);
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
        mpCallback->OnGetLiveRoomAllFansList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
