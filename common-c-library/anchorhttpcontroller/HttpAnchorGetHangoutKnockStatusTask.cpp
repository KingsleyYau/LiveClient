/*
 * HttpAnchorGetHangoutKnockStatusTask.cpp
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.6.获取敲门状态
 */

#include "HttpAnchorGetHangoutKnockStatusTask.h"

HttpAnchorGetHangoutKnockStatusTask::HttpAnchorGetHangoutKnockStatusTask() {
	// TODO Auto-generated constructor stub
	mPath = GETHANGOUTKNOCKSTATUS_PATH;
    mKnockId = "";
}

HttpAnchorGetHangoutKnockStatusTask::~HttpAnchorGetHangoutKnockStatusTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorGetHangoutKnockStatusTask::SetCallback(IRequestAnchorGetHangoutKnockStatusCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorGetHangoutKnockStatusTask::SetParam(
                                                   const string& knockId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (knockId.length() > 0) {
        mHttpEntiy.AddContent(GETHANGOUTKNOCKSTATUS_KNOCKID, knockId.c_str());
        mKnockId = knockId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetHangoutKnockStatusTask::SetParam( "
            "task : %p, "
            "knockId : %s ,"
            ")",
            this,
            knockId.c_str()
            );
}

bool HttpAnchorGetHangoutKnockStatusTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorGetHangoutKnockStatusTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAnchorGetHangoutKnockStatusTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string roomId = "";
    int expire = 0;
    AnchorMultiKnockType status = ANCHORMULTIKNOCKTYPE_UNKNOW;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[GETHANGOUTKNOCKSTATUS_ROOMID].isString()) {
                    roomId = dataJson[GETHANGOUTKNOCKSTATUS_ROOMID].asString();
                }
                
                if (dataJson[GETHANGOUTKNOCKSTATUS_STATUS].isNumeric()) {
                    status = (AnchorMultiKnockType)dataJson[GETHANGOUTKNOCKSTATUS_STATUS].asInt();
                }
                
                if (dataJson[GETHANGOUTKNOCKSTATUS_EXPIRE].isNumeric()) {
                    expire = dataJson[GETHANGOUTKNOCKSTATUS_EXPIRE].asInt();
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
        mpCallback->OnAnchorGetHangoutKnockStatus(this, bParse, errnum, errmsg, roomId, status, expire);
    }
    
    return bParse;
}

