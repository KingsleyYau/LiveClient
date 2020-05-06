/*
 * HttpGetScheduleInviteListTask.cpp
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.7.获取预付费直播邀请列表
 */

#include "HttpGetScheduleInviteListTask.h"

HttpGetScheduleInviteListTask::HttpGetScheduleInviteListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETINVITELIST;
}

HttpGetScheduleInviteListTask::~HttpGetScheduleInviteListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetScheduleInviteListTask::SetCallback(IRequestGetScheduleInviteListCallback* callback) {
	mpCallback = callback;
}

void HttpGetScheduleInviteListTask::SetParam(
                                          LSScheduleInviteStatus status,
                                          LSScheduleSendFlagType sendFlag,
                                          string anchorId,
                                          int start,
                                          int step
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    snprintf(temp, sizeof(temp), "%d", GetLSScheduleInviteStatusToInt(status));
    mHttpEntiy.AddContent(LIVEROOM_GETINVITELIST_STATUS, temp);
    
    snprintf(temp, sizeof(temp), "%d", GetLSScheduleSendFlagTypeToInt(sendFlag));
    mHttpEntiy.AddContent(LIVEROOM_GETINVITELIST_SEND_FLAG, temp);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_GETINVITELIST_ANCHOR_INFO_ANCHOR_ID, anchorId.c_str());
    }
        
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_GETINVITELIST_START, temp);
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_GETINVITELIST_STEP, temp);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteListTask::SetParam( "
            "task : %p, "
            "status : %d, "
            "sendFlag : %d, "
            "anchorId : %s, "
            "start : %d, "
            "step : %d"
            ")",
            this,
            status,
            sendFlag,
            anchorId.c_str(),
            start,
            step
            );
}

bool HttpGetScheduleInviteListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetScheduleInviteListTask::ParseData( "
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
    ScheduleInviteList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson[LIVEROOM_GETINVITELIST_LIST].isArray()) {
                for (int i = 0; i < dataJson[LIVEROOM_GETINVITELIST_LIST].size(); i++) {
                    Json::Value element = dataJson[LIVEROOM_GETINVITELIST_LIST].get(i, Json::Value::null);
                    HttpScheduleInviteListItem item;
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
        mpCallback->OnGetScheduleInviteList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

