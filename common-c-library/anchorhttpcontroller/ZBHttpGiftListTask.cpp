/*
 *  ZBHttpGiftListTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.4.获取主播直播间礼物列表
 */

#include "ZBHttpGiftListTask.h"

ZBHttpGiftListTask::ZBHttpGiftListTask() {
	// TODO Auto-generated constructor stub
	mPath = GIFTLIST_PATH;
    mRoomId = "";

}

ZBHttpGiftListTask::~ZBHttpGiftListTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGiftListTask::SetCallback(IRequestZBGiftListCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGiftListTask::SetParam(
                                  const string roomId
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(GIFTLIST_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGiftListTask::SetParam( "
            "task : %p, "
            "roomId : %s"
            ")",
            this,
            roomId.c_str()
            );
}


bool ZBHttpGiftListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGiftListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    ZBHttpGiftLimitNumItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[GIFTLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[GIFTLIST_LIST].size(); i++) {
                        ZBHttpGiftLimitNumItem item;
                        item.Parse(dataJson[GIFTLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnZBGiftList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
