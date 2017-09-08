/*
 * HttpGetTalentListTask.cpp
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *        desc: 3.10.获取才艺点播列表
 */

#include "HttpGetTalentListTask.h"

HttpGetTalentListTask::HttpGetTalentListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETTALENTLIST;
    mRoomId = "";
}

HttpGetTalentListTask::~HttpGetTalentListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetTalentListTask::SetCallback(IRequestGetTalentListCallback* callback) {
	mpCallback = callback;
}

void HttpGetTalentListTask::SetParam(
                                     const string roomId
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETTALENTLIST_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog("httpcontroller",
            "HttpGetTalentListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

/**
 *  邀请ID
 */
const string& HttpGetTalentListTask::GetRoomId() {
    return mRoomId;
}


bool HttpGetTalentListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetTalentListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetTalentListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
   TalentItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                
                if( dataJson[LIVEROOM_GETTALENTLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_GETTALENTLIST_LIST].size(); i++) {
                        HttpGetTalentItem item;
                        item.Parse(dataJson[LIVEROOM_GETTALENTLIST_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
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
        mpCallback->OnGetTalentList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}

