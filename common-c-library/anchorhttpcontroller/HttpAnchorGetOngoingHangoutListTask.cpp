/*
 * HttpAnchorGetOngoingHangoutListTask.cpp
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.4.获取未结束的多人互动直播间列表
 */

#include "HttpAnchorGetOngoingHangoutListTask.h"

HttpAnchorGetOngoingHangoutListTask::HttpAnchorGetOngoingHangoutListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETONGOINGHANGOUTLIST_PATH;
    mStart = 0;
    mStep = 0;
}

HttpAnchorGetOngoingHangoutListTask::~HttpAnchorGetOngoingHangoutListTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetOngoingHangoutListTask::SetCallback(IRequestAnchorGetOngoingHangoutListCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetOngoingHangoutListTask::SetParam(
                                                   int start,
                                                   int step
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(GETONGOINGHANGOUTLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(GETONGOINGHANGOUTLIST_STEP, temp);
    mStep = step;
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetOngoingHangoutListTask::SetParam( "
            "task : %p, "
            "start : %d ,"
            "step : %d"
            ")",
            this,
            start,
            step
            );
}

bool HttpAnchorGetOngoingHangoutListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetOngoingHangoutListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetOngoingHangoutListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpAnchorHangoutItemList hangoutList;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[GETONGOINGHANGOUTLIST_HANGOUTLIST].isArray()) {
                    int i = 0;
                    for ( i = 0; i < dataJson[GETONGOINGHANGOUTLIST_HANGOUTLIST].size(); i++) {
                        HttpAnchorHangoutItem item;
                        item.Parse(dataJson[GETONGOINGHANGOUTLIST_HANGOUTLIST].get(i, Json::Value::null));
                        hangoutList.push_back(item);
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
        mpCallback->OnAnchorGetOngoingHangoutList(this, bParse, errnum, errmsg, hangoutList);
    }
    
    return bParse;
}

