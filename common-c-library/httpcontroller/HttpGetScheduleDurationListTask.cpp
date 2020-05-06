/*
 * HttpGetScheduleDurationListTask.cpp
 *
 *  Created on: 2020-3-16
 *      Author: Alex
 *        desc: 17.1.获取时长价格配置列表
 */

#include "HttpGetScheduleDurationListTask.h"

HttpGetScheduleDurationListTask::HttpGetScheduleDurationListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETSCHEDULEDURATIONLIST;
}

HttpGetScheduleDurationListTask::~HttpGetScheduleDurationListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetScheduleDurationListTask::SetCallback(IRequestGetScheduleDurationListCallback* callback) {
	mpCallback = callback;
}

void HttpGetScheduleDurationListTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleDurationListTask::SetParam( "
            "task : %p"
            ")",
            this
            );
}

bool HttpGetScheduleDurationListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleDurationListTask::ParseData( "
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
    bool bParse = false;
    ScheduleDurationList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isArray()) {
                for (int i = 0; i < dataJson.size(); i++) {
                    Json::Value element = dataJson.get(i, Json::Value::null);
                    HttpScheduleDurationItem item;
                    if (item.Parse(element)) {
                        list.push_back(item);
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
        mpCallback->OnGetScheduleDurationList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

