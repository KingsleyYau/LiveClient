/*
 * HttpAnchorGetProgramListTask.cpp
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.1.获取节目列表
 */

#include "HttpAnchorGetProgramListTask.h"

HttpAnchorGetProgramListTask::HttpAnchorGetProgramListTask() {
	// TODO Auto-generated constructor stub
	mPath = ANCHORGETPROGRAMLIST_PATH;
    mStart = 0;
    mStep = 0;
    mStatus = ANCHORPROGRAMLISTTYPE_UNKNOW;
}

HttpAnchorGetProgramListTask::~HttpAnchorGetProgramListTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetProgramListTask::SetCallback(IRequestAnchorGetProgramListCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetProgramListTask::SetParam(
                                            int start,
                                            int step,
                                            AnchorProgramListType status
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(ANCHORGETPROGRAMLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(ANCHORGETPROGRAMLIST_STEP, temp);
    mStep = step;
    
    if (status > ANCHORPROGRAMLISTTYPE_UNKNOW && status <= ANCHORPROGRAMLISTTYPE_HISTORY) {
        snprintf(temp, sizeof(temp), "%d", status);
        mHttpEntiy.AddContent(ANCHORGETPROGRAMLIST_STATUS, temp);
        mStatus = status;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetProgramListTask::SetParam( "
            "task : %p, "
            "start : %d ,"
            "step : %d ,"
            "status : %d ,"
            ")",
            this,
            start,
            step,
            status
            );
}

bool HttpAnchorGetProgramListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetProgramListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetProgramListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    AnchorProgramInfoList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                // 业务解析
                if (dataJson[ANCHORGETPROGRAMLIST_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[ANCHORGETPROGRAMLIST_LIST].size(); i++) {
                        HttpAnchorProgramInfoItem item;
                        item.Parse(dataJson[ANCHORGETPROGRAMLIST_LIST].get(i, Json::Value::null));
                        list.push_back(item);
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
        mpCallback->OnAnchorGetProgramList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

