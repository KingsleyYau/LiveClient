/*
 * HttpAnchorCheckIsPlayProgramTask.cpp
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.4.检测是否开播节目直播
 */

#include "HttpAnchorCheckIsPlayProgramTask.h"

HttpAnchorCheckIsPlayProgramTask::HttpAnchorCheckIsPlayProgramTask() {
	// TODO Auto-generated constructor stub
	mPath = ANCHORCHECKISPLAYPROGRA_PATH;
}

HttpAnchorCheckIsPlayProgramTask::~HttpAnchorCheckIsPlayProgramTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorCheckIsPlayProgramTask::SetCallback(IRequestAnchorCheckIsPlayProgramCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorCheckIsPlayProgramTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorCheckIsPlayProgramTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpAnchorCheckIsPlayProgramTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorCheckIsPlayProgramTask::ParseData( "
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
    
    AnchorPublicRoomType liveShowType = ANCHORPUBLICROOMTYPE_UNKNOW;
    string liveShowId = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                // 业务解析
                if (dataJson[ANCHORCHECKISPLAYPROGRA_LIVESHOWTYPE].isNumeric()) {
                    liveShowType = (AnchorPublicRoomType)dataJson[ANCHORCHECKISPLAYPROGRA_LIVESHOWTYPE].asInt();
                }
                if (dataJson[ANCHORCHECKISPLAYPROGRA_LIVESHOWID].isString()) {
                    liveShowId = dataJson[ANCHORCHECKISPLAYPROGRA_LIVESHOWID].asString();
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
        mpCallback->OnAnchorCheckPublicRoomType(this, bParse, errnum, errmsg, liveShowType, liveShowId);
    }
    
    return bParse;
}

