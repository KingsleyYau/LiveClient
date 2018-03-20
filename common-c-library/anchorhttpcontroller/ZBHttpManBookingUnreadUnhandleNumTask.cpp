/*
 * ZBHttpManBookingUnreadUnhandleNumTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.4.获取预约邀请未读或待处理数量
 */

#include "ZBHttpManBookingUnreadUnhandleNumTask.h"

ZBHttpManBookingUnreadUnhandleNumTask::ZBHttpManBookingUnreadUnhandleNumTask() {
	// TODO Auto-generated constructor stub
	mPath = GETSCHEDULELISTNOREADNUM_PATH ;
}

ZBHttpManBookingUnreadUnhandleNumTask::~ZBHttpManBookingUnreadUnhandleNumTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpManBookingUnreadUnhandleNumTask::SetCallback(IRequestZBGetScheduleListNoReadNumCallback* callback) {
	mpCallback = callback;
}


void ZBHttpManBookingUnreadUnhandleNumTask::SetParam(
                                    ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpManBookingUnreadUnhandleNumTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool ZBHttpManBookingUnreadUnhandleNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpManBookingUnreadUnhandleNumTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpManBookingUnreadUnhandleNumTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    ZBHttpBookingUnreadUnhandleNumItem item;
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
        mpCallback->OnZBGetScheduleListNoReadNum(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

