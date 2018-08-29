/*
 * ZBHttpGetConfigTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 5.1.同步配置
 */

#include "ZBHttpGetConfigTask.h"

ZBHttpGetConfigTask::ZBHttpGetConfigTask() {
	// TODO Auto-generated constructor stub
	mPath = GETCONFIG_PATH;
}

ZBHttpGetConfigTask::~ZBHttpGetConfigTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetConfigTask::SetCallback(IRequestZBGetConfigCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetConfigTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetConfigTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

bool ZBHttpGetConfigTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetConfigTask::ParseData( "
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
    ZBHttpConfigItem item;
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
        mpCallback->OnZBGetConfig(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

