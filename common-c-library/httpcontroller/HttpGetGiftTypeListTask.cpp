/*
 * HttpGetGiftTypeListTask.cpp
 *
 *  Created on: 2019-08-27
 *      Author: Alex
 *        desc: 3.17.获取虚拟礼物分类列表
 */

#include "HttpGetGiftTypeListTask.h"

HttpGetGiftTypeListTask::HttpGetGiftTypeListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETTYPELIST;
    
}

HttpGetGiftTypeListTask::~HttpGetGiftTypeListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetGiftTypeListTask::SetCallback(IRequestGetGiftTypeListtCallback* callback) {
	mpCallback = callback;
}

void HttpGetGiftTypeListTask::SetParam(
                                      LSGiftRoomType roomType
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (roomType > LSGIFTROOMTYPE_BEGIN && roomType <= LSGIFTROOMTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", roomType );
        mHttpEntiy.AddContent(LIVEROOM_GETTYPELIST_ROOMTYPE, temp);
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftTypeListTask::SetParam( "
            "task : %p, "
            "roomType : %d"
            ")",
            this,
            roomType
            );
}


bool HttpGetGiftTypeListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetGiftTypeListTask::ParseData( "
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
    GiftTypeList typeList;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson.size(); i++) {
                    HttpGiftTypeItem item;
                    item.Parse(dataJson.get(i, Json::Value::null));
                    typeList.push_back(item);
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
        mpCallback->OnGetGiftTypeList(this, bParse, errnum, errmsg, typeList);
    }
    
    return bParse;
}

