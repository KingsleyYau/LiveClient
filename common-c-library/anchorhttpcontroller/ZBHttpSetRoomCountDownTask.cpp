/*
 * ZBHttpSetRoomCountDownTask.cpp
 *
 *  Created on: 2018-3-9
 *      Author: Alex
 *        desc: 4.9.设置直播间为开始倒数
 */

#include "ZBHttpSetRoomCountDownTask.h"

ZBHttpSetRoomCountDownTask::ZBHttpSetRoomCountDownTask() {
	// TODO Auto-generated constructor stub
	mPath = SETROOMCOUNTDOWN_PATH;
    mRoomId = "";

}

ZBHttpSetRoomCountDownTask::~ZBHttpSetRoomCountDownTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpSetRoomCountDownTask::SetCallback(IRequestZBSetRoomCountDownCallback* callback) {
	mpCallback = callback;
}

void ZBHttpSetRoomCountDownTask::SetParam(
                                            const string& roomId
                                          ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(SETROOMCOUNTDOWN_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }


    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetRoomCountDownTask::SetParam( "
            "task : %p, "
            "roomId : %s ,"
            ")",
            this,
            roomId.c_str()
            );
}


bool ZBHttpSetRoomCountDownTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpSetRoomCountDownTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpSetRoomCountDownTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBSetRoomCountDown(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

