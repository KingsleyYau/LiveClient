/*
 * ZBHttpGetScheduledAcceptNumTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)
 */

#include "ZBHttpGetScheduledAcceptNumTask.h"

ZBHttpGetScheduledAcceptNumTask::ZBHttpGetScheduledAcceptNumTask() {
	// TODO Auto-generated constructor stub
	mPath = GETSCHEDULEDACCEPTNUM_PATH ;
}

ZBHttpGetScheduledAcceptNumTask::~ZBHttpGetScheduledAcceptNumTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetScheduledAcceptNumTask::SetCallback(IRequestZBGetScheduledAcceptNumCallback* callback) {
	mpCallback = callback;
}


void ZBHttpGetScheduledAcceptNumTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetScheduledAcceptNumTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool ZBHttpGetScheduledAcceptNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetScheduledAcceptNumTask::ParseData( "
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
    int scheduledNum = 0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                /* scheduledNum */
                if (dataJson[GETSCHEDULEDACCEPTNUM_SCHEDULEDNUM ].isInt()) {
                    scheduledNum = dataJson[GETSCHEDULEDACCEPTNUM_SCHEDULEDNUM ].asInt();
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
        mpCallback->OnZBGetScheduledAcceptNum(this, bParse, errnum, errmsg, scheduledNum);
    }
    
    return bParse;
}

