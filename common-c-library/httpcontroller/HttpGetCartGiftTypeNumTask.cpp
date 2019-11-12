/*
 * HttpGetCartGiftTypeNumTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.6.获取购物车礼品种类数
 */

#include "HttpGetCartGiftTypeNumTask.h"

HttpGetCartGiftTypeNumTask::HttpGetCartGiftTypeNumTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCARTGIFTTYPENUM;
    
}

HttpGetCartGiftTypeNumTask::~HttpGetCartGiftTypeNumTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCartGiftTypeNumTask::SetCallback(IRequestGetCartGiftTypeNumCallback* callback) {
	mpCallback = callback;
}

void HttpGetCartGiftTypeNumTask::SetParam(
                                      const string& anchorId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( anchorId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETCARTGIFTTYPENUM_ANCHORID, anchorId.c_str());

    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCartGiftTypeNumTask::SetParam( "
            "task : %p, "
            "anchorId : %s"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpGetCartGiftTypeNumTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCartGiftTypeNumTask::ParseData( "
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
    int num = 0;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETCARTGIFTTYPENUM_NUM].isNumeric()) {
                    num = dataJson[LIVEROOM_GETCARTGIFTTYPENUM_NUM].asInt();
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
        mpCallback->OnGetCartGiftTypeNum(this, bParse, errnum, errmsg, num);
    }
    
    return bParse;
}

