/*
 * HttpGetProgramListTask.cpp
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.2.获取节目列表
 */

#include "HttpGetProgramListTask.h"

HttpGetProgramListTask::HttpGetProgramListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETPROGRAMLIST_PATH;
    mStart = 0;
    mStep = 0;
    mSortType = PROGRAMLISTTYPE_UNKNOW;
}

HttpGetProgramListTask::~HttpGetProgramListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetProgramListTask::SetCallback(IRequestGetProgramListCallback* callback) {
	mpCallback = callback;
}

void HttpGetProgramListTask::SetParam(
                                      ProgramListType sortType,
                                      int start,
                                      int step
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    if (sortType > PROGRAMLISTTYPE_UNKNOW && sortType <= PROGRAMLISTTYPE_HISTORY) {
        snprintf(temp, sizeof(temp), "%d", sortType);
        mHttpEntiy.AddContent(GETPROGRAMLIST_SORTTYPE, temp);
        mSortType = sortType;
    }
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(GETPROGRAMLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(GETPROGRAMLIST_STEP, temp);
    mStep = step;
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetProgramListTask::SetParam( "
            "task : %p, "
            "sortType : %d ,"
            "start : %d ,"
            "step : %d ,"
            ")",
            this,
            sortType,
            start,
            step
            );
}

bool HttpGetProgramListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetProgramListTask::ParseData( "
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
    ProgramInfoList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[GETPROGRAMLIST_LIST].isArray()) {
                int i = 0;
                for (i = 0; i < dataJson[GETPROGRAMLIST_LIST].size(); i++) {
                    HttpProgramInfoItem item;
                    item.Parse(dataJson[GETPROGRAMLIST_LIST].get(i, Json::Value::null));
                    list.push_back(item);
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
        mpCallback->OnGetProgramList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

