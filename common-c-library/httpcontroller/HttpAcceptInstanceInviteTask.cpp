/*
 * HttpGetPromoAnchorListTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 4.7.观众处理立即私密邀请
 */

#include "HttpAcceptInstanceInviteTask.h"

HttpAcceptInstanceInviteTask::HttpAcceptInstanceInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ACCEPTINSTACEINVITE;
    mInviteId = "";
    mIsConfirm = false;

}

HttpAcceptInstanceInviteTask::~HttpAcceptInstanceInviteTask() {
	// TODO Auto-generated destructor stub
}

void HttpAcceptInstanceInviteTask::SetCallback(IRequestAcceptInstanceInviteCallback* callback) {
	mpCallback = callback;
}

void HttpAcceptInstanceInviteTask::SetParam(
                                            const string& InviteId,
                                            bool isConfirm
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (InviteId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ACCEPTINSTACEINVITE_INVITEID, InviteId.c_str());
        mInviteId = InviteId;
    }

    snprintf(temp, sizeof(temp), "%d", isConfirm ? 1 : 0);
    mHttpEntiy.AddContent(LIVEROOM_ACCEPTINSTACEINVITE_ISCONFIRM, temp);
    mIsConfirm = isConfirm;

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAcceptInstanceInviteTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpAcceptInstanceInviteTask::GetInviteId() {
    return mInviteId;
}

bool HttpAcceptInstanceInviteTask::GetIsConfirm() {
    return mIsConfirm;
}

bool HttpAcceptInstanceInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAcceptInstanceInviteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpAcceptInstanceInviteTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpAcceptInstanceInviteItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
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
        mpCallback->OnAcceptInstanceInvite(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

