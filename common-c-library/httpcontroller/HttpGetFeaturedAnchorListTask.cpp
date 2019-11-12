/*
 * HttpGetFeaturedAnchorListTask.cpp
 *
 *  Created on: 2019-11-12
 *      Author: Alex
 *        desc: 3.18.Featured欄目的推荐主播列表
 */

#include "HttpGetFeaturedAnchorListTask.h"


HttpGetFeaturedAnchorListTask::HttpGetFeaturedAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETFEATUREDANCHORLIST;
    mStart = 0;
    mStep = 0;
    
}

HttpGetFeaturedAnchorListTask::~HttpGetFeaturedAnchorListTask() {
	// TODO Auto-generated destructor stub
    
    for( HotItemList::const_iterator iter = mItemList.begin(); iter != mItemList.end(); iter++) {
        delete (*iter);
    }

    
}

void HttpGetFeaturedAnchorListTask::SetCallback(IRequestGetFeaturedAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetFeaturedAnchorListTask::SetParam(
                                      int start,
                                      int step
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);


    char temp[16];
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_GETFEATUREDANCHORLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_GETFEATUREDANCHORLIST_STEP, temp);
    mStep = step;
    
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFeaturedAnchorListTask::SetParam( "
            "task : %p, "
            "start : %d, "
            "step : %d "
            ")",
            this,
            start,
            step
            );
}

int HttpGetFeaturedAnchorListTask::GetStart() {
    return mStart;
}

int HttpGetFeaturedAnchorListTask::GetStep() {
    return mStep;
}

bool HttpGetFeaturedAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFeaturedAnchorListTask::ParseData( "
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
   // HotItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpLiveRoomInfoItem* item = new HttpLiveRoomInfoItem();
                        item->Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                        mItemList.push_back(item);
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
        mpCallback->OnGetFeaturedAnchorList(this, bParse, errnum, errmsg, mItemList);
    }
    
    return bParse;
}
