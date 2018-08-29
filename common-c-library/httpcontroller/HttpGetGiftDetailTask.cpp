/*
 *  HttpGetGiftDetailTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）
 */

#include "HttpGetGiftDetailTask.h"

HttpGetGiftDetailTask::HttpGetGiftDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETGiftDetail;
    mGiftId = "";

}

HttpGetGiftDetailTask::~HttpGetGiftDetailTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetGiftDetailTask::SetCallback(IRequestGetGiftDetailCallback* callback) {
	mpCallback = callback;
}

void HttpGetGiftDetailTask::SetParam(
                                    string giftId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GiftID, giftId.c_str());
        mGiftId = giftId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftDetailTask::SetParam( "
            "task : %p, "
            "giftId : %s"
            ")",
            this,
            giftId.c_str()
            );
}

const string& HttpGetGiftDetailTask::GetGiftId() {
    return mGiftId;
}


bool HttpGetGiftDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftDetailTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    HttpGiftInfoItem item;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson.isObject() ) {
                item.Parse(dataJson);
            }

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetGiftDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
