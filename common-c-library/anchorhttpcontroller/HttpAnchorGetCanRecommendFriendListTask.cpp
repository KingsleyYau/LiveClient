/*
 * HttpAnchorGetCanRecommendFriendListTask.cpp
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.1.获取可推荐的好友列表
 */

#include "HttpAnchorGetCanRecommendFriendListTask.h"

HttpAnchorGetCanRecommendFriendListTask::HttpAnchorGetCanRecommendFriendListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETCANRECOMMENDFRIENDLIST_PATH;
    mStart = 0;
    mStep = 0;
}

HttpAnchorGetCanRecommendFriendListTask::~HttpAnchorGetCanRecommendFriendListTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetCanRecommendFriendListTask::SetCallback(IRequestAnchorGetCanRecommendFriendListCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetCanRecommendFriendListTask::SetParam(
                                                       int start,
                                                       int step
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(GETCANRECOMMENDFRIENDLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(GETCANRECOMMENDFRIENDLIST_STEP, temp);
    mStep = step;
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetCanRecommendFriendListTask::SetParam( "
            "task : %p, "
            "start : %d ,"
            "step : %d"
            ")",
            this,
            start,
            step
            );
}

bool HttpAnchorGetCanRecommendFriendListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetCanRecommendFriendListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetCanRecommendFriendListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpAnchorItemList anchorList;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[GETCANRECOMMENDFRIENDLIST_ANCHORLIST].isArray()) {
                    int i = 0;
                    for ( i = 0; i < dataJson[GETCANRECOMMENDFRIENDLIST_ANCHORLIST].size(); i++) {
                        HttpAnchorItem item;
                        item.Parse(dataJson[GETCANRECOMMENDFRIENDLIST_ANCHORLIST].get(i, Json::Value::null));
                        anchorList.push_back(item);
                    }
                }
                
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAnchorGetCanRecommendFriendList(this, bParse, errnum, errmsg, anchorList);
    }
    
    return bParse;
}

