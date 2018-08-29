/*
 *  ZBHttpGetAllGiftListTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.3.获取礼物列表
 */

#include "ZBHttpGetAllGiftListTask.h"

ZBHttpGetAllGiftListTask::ZBHttpGetAllGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETALLGIFTLIST_PATH;

}

ZBHttpGetAllGiftListTask::~ZBHttpGetAllGiftListTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetAllGiftListTask::SetCallback(IRequestZBGetAllGiftListCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetAllGiftListTask::SetParam(
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetAllGiftListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool ZBHttpGetAllGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetAllGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    ZBGiftItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[GETALLGIFTLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[GETALLGIFTLIST_LIST].size(); i++) {
                        ZBHttpGiftInfoItem item;
                        item.Parse(dataJson[GETALLGIFTLIST_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
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
        mpCallback->OnZBGetAllGiftList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
