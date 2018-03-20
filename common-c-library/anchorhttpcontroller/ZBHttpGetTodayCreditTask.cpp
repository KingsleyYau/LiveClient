/*
 * ZBHttpGetTodayCreditTask.cpp
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 5.2.获取收入信息
 */

#include "ZBHttpGetTodayCreditTask.h"

ZBHttpGetTodayCreditTask::ZBHttpGetTodayCreditTask() {
	// TODO Auto-generated constructor stub
	mPath = GETTODAYCREDIT_PATH;
}

ZBHttpGetTodayCreditTask::~ZBHttpGetTodayCreditTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetTodayCreditTask::SetCallback(IRequestZBGetTodayCreditCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetTodayCreditTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetTodayCreditTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

bool ZBHttpGetTodayCreditTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetTodayCreditTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpGetTodayCreditTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    ZBHttpTodayCreditItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBGetTodayCredit(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

