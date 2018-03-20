/*
 * ZBHttpAcceptInstanceInviteTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 4.7.观众处理立即私密邀请
 */

#include "ZBHttpAcceptInstanceInviteTask.h"

ZBHttpAcceptInstanceInviteTask::ZBHttpAcceptInstanceInviteTask() {
	// TODO Auto-generated constructor stub
	mPath = ACCEPTINSTANCEINVITE_PATH;
    mInviteId = "";

}

ZBHttpAcceptInstanceInviteTask::~ZBHttpAcceptInstanceInviteTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpAcceptInstanceInviteTask::SetCallback(IRequestZBAcceptInstanceInviteCallback* callback) {
	mpCallback = callback;
}

void ZBHttpAcceptInstanceInviteTask::SetParam(
                                            const string& InviteId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (InviteId.length() >  0 ) {
        mHttpEntiy.AddContent(ACCEPTINSTANCEINVITE_INVITEID, InviteId.c_str());
        mInviteId = InviteId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpAcceptInstanceInviteTask::SetParam( "
            "task : %p, "
            "InviteId : %s ,"
            ")",
            this,
            InviteId.c_str()
            );
}

const string& ZBHttpAcceptInstanceInviteTask::GetInviteId() {
    return mInviteId;
}


bool ZBHttpAcceptInstanceInviteTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpAcceptInstanceInviteTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpAcceptInstanceInviteTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string roomId = "";
    ZBHttpRoomType roomType = ZBHTTPROOMTYPE_NOLIVEROOM;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                /* roomId */
                if (dataJson[ACCEPTINSTANCEINVITE_ROOMID].isString()) {
                    roomId = dataJson[ACCEPTINSTANCEINVITE_ROOMID].asString();
                }
                
                /* roomType */
                if (dataJson[ACCEPTINSTANCEINVITE_ROOMTYPE].isIntegral()) {
                    roomType = (ZBHttpRoomType)dataJson[ACCEPTINSTANCEINVITE_ROOMTYPE].asInt();
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
        mpCallback->OnZBAcceptInstanceInvite(this, bParse, errnum, errmsg, roomId, roomType);
    }
    
    return bParse;
}

