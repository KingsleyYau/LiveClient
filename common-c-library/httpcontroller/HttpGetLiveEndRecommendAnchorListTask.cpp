/*
 * HttpGetLiveEndRecommendAnchorListTask.cpp
 *
 *  Created on: 2019-6-11
 *      Author: Alex
 *        desc: 3.15.获取页面推荐的主播列表
 */

#include "HttpGetLiveEndRecommendAnchorListTask.h"

HttpGetLiveEndRecommendAnchorListTask::HttpGetLiveEndRecommendAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETPAGERECOMMENDANCHORLIST;

}

HttpGetLiveEndRecommendAnchorListTask::~HttpGetLiveEndRecommendAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetLiveEndRecommendAnchorListTask::SetCallback(IRequestGetLiveEndRecommendAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetLiveEndRecommendAnchorListTask::SetParam(

                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", 5 );
    mHttpEntiy.AddContent(LIVEROOM_GETPAGERECOMMENDANCHORLIST_TYPE, temp);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPromoAnchorListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetLiveEndRecommendAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetLiveEndRecommendAnchorListTask::ParseData( "
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
    RecommendAnchorList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].size(); i++) {
                        HttpRecommendAnchorItem item;
                        item.Parse(dataJson[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetLiveEndRecommendAnchorList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}

