/*
 * HttpGetAnchorListTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.1.获取Hot列表
 */

#include "HttpGetAnchorListTask.h"


HttpGetAnchorListTask::HttpGetAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETANCHORLIST;
    mStart = 0;
    mStep = 0;
    mIsForTest = false;
}

HttpGetAnchorListTask::~HttpGetAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetAnchorListTask::SetCallback(IRequestGetAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetAnchorListTask::SetParam(
                                      int start,
                                      int step,
                                      bool hasWatch,
                                      bool isForTest
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    char temp[16];
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_STEP, temp);
    mStep = step;
    
    snprintf(temp, sizeof(temp), "%d", hasWatch ? 1 : 0);
    mHttpEntiy.AddContent(LIVEROOM_HOT_HASWATCH, temp);
    mHasWatch = hasWatch;
    
    // isForTest为零不传参数
    if (isForTest == true) {
        snprintf(temp, sizeof(temp), "%d", isForTest ? 1 : 0);
        mHttpEntiy.AddContent(LIVEROOM_HOT_ISFORTEST, temp);
        mIsForTest = isForTest;
    }
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAnchorListTask::SetParam( "
            "task : %p, "
            "start : %d, "
            "step : %d, "
            "hasWatch:%d,"
            "isForTest:%d,"
            ")",
            this,
            start,
            step,
            hasWatch,
            isForTest
            );
}

int HttpGetAnchorListTask::GetStart() {
    return mStart;
}

int HttpGetAnchorListTask::GetStep() {
    return mStep;
}

bool HttpGetAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetAnchorListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetAnchorListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HotItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpLiveRoomInfoItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
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
        mpCallback->OnGetAnchorList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
