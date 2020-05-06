/*
 * HttpGetSessionInviteListTask.cpp
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.9.获取某会话中预付费直播邀请列表
 */

#include "HttpGetSessionInviteListTask.h"

HttpGetSessionInviteListTask::HttpGetSessionInviteListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETSESSIONINVITELIST;
}

HttpGetSessionInviteListTask::~HttpGetSessionInviteListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetSessionInviteListTask::SetCallback(IRequestGetSessionInviteListCallback* callback) {
	mpCallback = callback;
}

void HttpGetSessionInviteListTask::SetParam(
                                          LSScheduleInviteType type,
                                          string refId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", GetLSScheduleInviteTypeToInt(type));
    mHttpEntiy.AddContent(LIVEROOM_GETSESSIONINVITELIST_TYPE, temp);
    
    
    if (refId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETSESSIONINVITELIST_REF_ID, refId.c_str());
    }
        
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSessionInviteListTask::SetParam( "
            "task : %p, "
            "type : %d, "
            "refId : %s "
            ")",
            this,
            type,
            refId.c_str()
            );
}

bool HttpGetSessionInviteListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetSessionInviteListTask::ParseData( "
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
    LiveScheduleInviteList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson[LIVEROOM_GETSESSIONINVITELIST_LIST].isArray()) {
                for (int i = 0; i < dataJson[LIVEROOM_GETSESSIONINVITELIST_LIST].size(); i++) {
                    Json::Value element = dataJson[LIVEROOM_GETSESSIONINVITELIST_LIST].get(i, Json::Value::null);
                    HttpLiveScheduleInviteItem item;
                    if (item.Parse(element)) {
                        list.push_back(item);
                    }
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
        mpCallback->OnGetSessionInviteList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

