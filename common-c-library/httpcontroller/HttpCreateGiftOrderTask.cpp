/*
 * HttpCreateGiftOrderTask.cpp
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.12.生成订单
 */

#include "HttpCreateGiftOrderTask.h"

HttpCreateGiftOrderTask::HttpCreateGiftOrderTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CREATEGIFTORDER;
    
}

HttpCreateGiftOrderTask::~HttpCreateGiftOrderTask() {
	// TODO Auto-generated destructor stub
}

void HttpCreateGiftOrderTask::SetCallback(IRequestCreateGiftOrderCallback* callback) {
	mpCallback = callback;
}

void HttpCreateGiftOrderTask::SetParam(
                                       const string& anchorId,
                                       const string& greetingMessage,
                                       const string& specialDeliveryRequest
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_CREATEGIFTORDER_ANCHORID, anchorId.c_str());
    }
    
    if (greetingMessage.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_CREATEGIFTORDER_GREETINGMESSAGE, greetingMessage.c_str());
    }
    
    if (specialDeliveryRequest.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_CREATEGIFTORDER_SPECIALDELIVERYREQUEST, specialDeliveryRequest.c_str());
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCreateGiftOrderTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "greetingMessage : %s, "
            "specialDeliveryRequest : %s, "
            ")",
            this,
            anchorId.c_str(),
            greetingMessage.c_str(),
            specialDeliveryRequest.c_str()
            );
}


bool HttpCreateGiftOrderTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCreateGiftOrderTask::ParseData( "
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
    string orderNumber = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_CREATEGIFTORDER_ORDERNUMBER].isString()) {
                    orderNumber = dataJson[LIVEROOM_CREATEGIFTORDER_ORDERNUMBER].asString();
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
        mpCallback->OnCreateGiftOrder(this, bParse, errnum, errmsg, orderNumber);
    }
    
    return bParse;
}

