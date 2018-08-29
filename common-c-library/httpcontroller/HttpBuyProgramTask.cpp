/*
 * HttpBuyProgramTask.cpp
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.4.购买
 */

#include "HttpBuyProgramTask.h"

HttpBuyProgramTask::HttpBuyProgramTask() {
	// TODO Auto-generated constructor stub
	mPath = BUYPROGRAM_PATH;
    mLiveShowId = "";
}

HttpBuyProgramTask::~HttpBuyProgramTask() {
	// TODO Auto-generated destructor stub
}

void HttpBuyProgramTask::SetCallback(IRequestBuyProgramCallback* callback) {
	mpCallback = callback;
}

void HttpBuyProgramTask::SetParam(
                                   const string& liveShowId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (liveShowId.length() > 0) {
        mHttpEntiy.AddContent(BUYPROGRAM_LIVESHOWID, liveShowId.c_str());
        mLiveShowId = liveShowId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBuyProgramTask::SetParam( "
            "task : %p, "
            "mLiveShowId : %s ,"
            ")",
            this,
            mLiveShowId.c_str()
            );
}

bool HttpBuyProgramTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBuyProgramTask::ParseData( "
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
    double leftCredit = 0.0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson.isObject()) {
                if (dataJson[BUYPROGRAM_LEFTCREDIT].isNumeric()) {
                    leftCredit = dataJson[BUYPROGRAM_LEFTCREDIT].asDouble();
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
        mpCallback->OnBuyProgram(this, bParse, errnum, errmsg, leftCredit);
    }
    
    return bParse;
}

