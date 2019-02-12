/*
 * HttpGetSendMailPriceTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.8.获取发送信件所需的余额
 */

#include "HttpGetSendMailPriceTask.h"

HttpGetSendMailPriceTask::HttpGetSendMailPriceTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETSENDMAILPRICE;

}

HttpGetSendMailPriceTask::~HttpGetSendMailPriceTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetSendMailPriceTask::SetCallback(IRequestGetSendMailPriceCallback* callback) {
	mpCallback = callback;
}

void HttpGetSendMailPriceTask::SetParam(
                                        int imgNumber
                                  ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    snprintf(temp, sizeof(temp), "%d", imgNumber);
    mHttpEntiy.AddContent(LIVEROOM_GETSENDMAILPRICE_IMGNUMBER, temp);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSendMailPriceTask::SetParam( "
            "task : %p, "
            "imgNumber : %d,"
            ")",
            this,
            imgNumber
            );
}


bool HttpGetSendMailPriceTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSendMailPriceTask::ParseData( "
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
    double creditPrice = 0.0;
    double stampPrice = 0.0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LIVEROOM_GETSENDMAILPRICE_CREDIT_PRICE].isNumeric()) {
                    creditPrice = dataJson[LIVEROOM_GETSENDMAILPRICE_CREDIT_PRICE].asDouble();
                }
                if (dataJson[LIVEROOM_GETSENDMAILPRICE_STAMP_PRICE].isNumeric()) {
                    stampPrice = dataJson[LIVEROOM_GETSENDMAILPRICE_STAMP_PRICE].asDouble();
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
        mpCallback->OnGetSendMailPrice(this, bParse, errnum, errmsg, creditPrice, stampPrice);
    }
    
    return bParse;
}

