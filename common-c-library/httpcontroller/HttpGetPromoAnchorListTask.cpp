/*
 * HttpGetPromoAnchorListTask.cpp
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *        desc: 3.14.获取推荐主播列表
 */

#include "HttpGetPromoAnchorListTask.h"

HttpGetPromoAnchorListTask::HttpGetPromoAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETPROMOANCHORLIST;
    mNumber = 0;
    mType = PROMOANCHORTYPE_LIVEROOM;
    mUserId = "";

}

HttpGetPromoAnchorListTask::~HttpGetPromoAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPromoAnchorListTask::SetCallback(IRequestGetPromoAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetPromoAnchorListTask::SetParam(
                                            int number,
                                            PromoAnchorType type,
                                            const string& userId
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (number >  0 ) {
        snprintf(temp, sizeof(temp), "%d", number );
        mHttpEntiy.AddContent(LIVEROOM_GETPROMOANCHORLIST_NUMBER, temp);
        mNumber = number;
    }

    if (type > PROMOANCHORTYPE_BEGIN && type <= PROMOANCHORTYPE_END ) {
        snprintf(temp, sizeof(temp), "%d", type );
        mHttpEntiy.AddContent(LIVEROOM_GETPROMOANCHORLIST_TYPE, temp);
        mType = type;
    }
    
    if (userId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETPROMOANCHORLIST_USERID, userId.c_str());
        mUserId = userId;
    }
    
    FileLog("httpcontroller",
            "HttpGetPromoAnchorListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

int HttpGetPromoAnchorListTask::GetNumber() {
    return mNumber;
}

bool HttpGetPromoAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetPromoAnchorListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetPromoAnchorListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HotItemList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        HttpLiveRoomInfoItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
                }
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetPromoAnchorList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}

