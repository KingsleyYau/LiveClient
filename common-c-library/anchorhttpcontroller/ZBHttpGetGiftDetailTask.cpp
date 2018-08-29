/*
 *  ZBHttpGetGiftDetailTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 3.5.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）
 */

#include "ZBHttpGetGiftDetailTask.h"

ZBHttpGetGiftDetailTask::ZBHttpGetGiftDetailTask() {
	// TODO Auto-generated constructor stub
	mPath = GETGIFTDETAIL_PATH;
    mGiftId = "";

}

ZBHttpGetGiftDetailTask::~ZBHttpGetGiftDetailTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetGiftDetailTask::SetCallback(IRequestZBGetGiftDetailCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetGiftDetailTask::SetParam(
                                    string giftId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( giftId.length() > 0 ) {
        mHttpEntiy.AddContent(GETGIFTDETAIL_GIFTID, giftId.c_str());
        mGiftId = giftId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetGiftDetailTask::SetParam( "
            "task : %p, "
            "giftId : %s"
            ")",
            this,
            giftId.c_str()
            );
}

const string& ZBHttpGetGiftDetailTask::GetGiftId() {
    return mGiftId;
}


bool ZBHttpGetGiftDetailTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetGiftDetailTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    
    ZBHttpGiftInfoItem item;
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBGetGiftDetail(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
