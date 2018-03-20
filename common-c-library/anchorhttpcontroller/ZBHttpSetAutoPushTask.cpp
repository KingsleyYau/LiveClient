/*
 * ZBHttpSetAutoPushTask.cpp
 *
 *  Created on: 2018-3-9
 *      Author: Alex
 *        desc: 3.8.设置主播公开直播间自动邀请状态
 */

#include "ZBHttpSetAutoPushTask.h"

ZBHttpSetAutoPushTask::ZBHttpSetAutoPushTask() {
	// TODO Auto-generated constructor stub
	mPath = SETAUTOPUSH_PATH;
    mStatus = ZBSETPUSHTYPE_CLOSE;

}

ZBHttpSetAutoPushTask::~ZBHttpSetAutoPushTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpSetAutoPushTask::SetCallback(IRequestZBSetAutoPushCallback* callback) {
	mpCallback = callback;
}

void ZBHttpSetAutoPushTask::SetParam(
                                            ZBSetPushType status
                                          ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", status);
    mHttpEntiy.AddContent(SETAUTOPUSH_STATUS, temp);
    mStatus = status;

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetAutoPushTask::SetParam( "
            "task : %p, "
            "status : %d ,"
            ")",
            this,
            status
            );
}


bool ZBHttpSetAutoPushTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetAutoPushTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpSetAutoPushTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBSetAutoPush(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

