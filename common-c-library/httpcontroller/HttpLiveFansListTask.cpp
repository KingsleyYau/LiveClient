/*
 * HttpLiveFansListTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.4.获取直播间观众头像列表
 */

#include "HttpLiveFansListTask.h"


HttpLiveFansListTask::HttpLiveFansListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_LIVEFANSLIST;
    mLiveRoomId = "";
    mPage = 0;
    mNumber = 0;
}

HttpLiveFansListTask::~HttpLiveFansListTask() {
	// TODO Auto-generated destructor stub
}

void HttpLiveFansListTask::SetCallback(IRequestLiveFansListCallback* callback) {
	mpCallback = callback;
}

void HttpLiveFansListTask::SetParam(
                                    string liveRoomId,
                                    int page,
                                    int number
                                    ) {

	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( liveRoomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_LIVEFANSLIST_LIVEROOMID, liveRoomId.c_str());
        mLiveRoomId = liveRoomId;
    }
    
    if (page > 0) {
        snprintf(temp, sizeof(temp), "%d", page);
        mHttpEntiy.AddContent(LIVEROOM_LIVEFANSLIST_PAGE, temp);
        mPage = page;
    }
    
    if (number > 0) {
        snprintf(temp, sizeof(temp), "%d", number);
        mHttpEntiy.AddContent(LIVEROOM_LIVEFANSLIST_NUMBER, temp);
        mNumber = number;
    }

    FileLog("httpcontroller",
            "HttpLiveFansListTask::SetParam( "
            "task : %p, "
            "liveRoomId : %s, "
            "page:%d,"
            "number:%d "
            ")",
            this,
            liveRoomId.c_str(),
            page,
            number
            );
}


const string& HttpLiveFansListTask::GetLiveRoomId() {
    return mLiveRoomId;
}

int HttpLiveFansListTask::GetPage() {
    return mPage;
}

int HttpLiveFansListTask::GetNumber() {
    return mNumber;
}

bool HttpLiveFansListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpLiveFansListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpLiveFansListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpLiveFansList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpLiveFansItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
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
        mpCallback->OnLiveFansList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
