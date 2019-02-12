/*
 * HttpGetEmfListTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.3.获取信件列表
 */

#include "HttpGetEmfListTask.h"

HttpGetEmfListTask::HttpGetEmfListTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_GETEMFLIST;

}

HttpGetEmfListTask::~HttpGetEmfListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetEmfListTask::SetCallback(IRequestGetEmfListCallback* callback) {
	mpCallback = callback;
}

void HttpGetEmfListTask::SetParam(
                                  LSEMFType   type,
                                  LSLetterTag tag,
                                  int start,
                                  int step
                                  ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    int tempType = LSEMFTYPE_INBOX;
    if (LSEMFTYPE_BEGIN< type && type <= LSEMFTYPE_END) {
        tempType = type;
    }
    snprintf(temp, sizeof(temp), "%d", tempType);
    mHttpEntiy.AddContent(LETTER_TYPE, temp);
    int tempTag = LSLETTERTAG_ALL;
    if (LSLETTERTAG_BEGIN< tag && tag <= LSLETTERTAG_END) {
        tempTag = tag;
    }
    snprintf(temp, sizeof(temp), "%d", tempTag);
    mHttpEntiy.AddContent(LETTER_TAG, temp);

    snprintf(temp, sizeof(temp), "%d", start > 0 ? start : 0);
    mHttpEntiy.AddContent(LETTER_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step > 0 ? step : 0);
    mHttpEntiy.AddContent(LETTER_STEP, temp);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfListTask::SetParam( "
            "task : %p, "
            "type : %d,"
            "tag : %d,"
            "start : %d,"
            "step : %d"
            ")",
            this,
            type,
            tag,
            start,
            step
            );
}


bool HttpGetEmfListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetEmfListTask::ParseData( "
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
    HttpLetterItemList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LETTER_LIST].isArray()) {
                    for (int i = 0; i < dataJson[LETTER_LIST].size(); i++) {
                        HttpLetterListItem item;
                        item.Parse(dataJson[LETTER_LIST].get(i, Json::Value::null), false);
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
        mpCallback->OnGetEmfList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

