/*
 * HttpControlManPushTask.cpp
 *
 *  Created on: 2017-8-30
 *      Author: Alex
 *        desc: 3.13.观众开始／结束视频互动（废弃）
 */

#include "HttpControlManPushTask.h"

HttpControlManPushTask::HttpControlManPushTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_CONTROLMANPUSH;
    mRoomId = "";
    mControl = CONTROLTYPE_UNKNOW;
}

HttpControlManPushTask::~HttpControlManPushTask() {
	// TODO Auto-generated destructor stub
}

void HttpControlManPushTask::SetCallback(IRequestControlManPushCallback* callback) {
	mpCallback = callback;
}

void HttpControlManPushTask::SetParam(
                                        const string& roomId,
                                        ControlType control
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( roomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_CONTROLMANPUSH_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    if (control >  CONTROLTYPE_UNKNOW && control <= CONTROLTYPE_CLOSE) {
        snprintf(temp, sizeof(temp), "%d", control );
        mHttpEntiy.AddContent(LIVEROOM_CONTROLMANPUSH_CONTROL, temp);
        mControl = control;
    }


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpControlManPushTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& HttpControlManPushTask::GetRoomId() {
    return mRoomId;
}

ControlType HttpControlManPushTask::GetControl() {
    return mControl;
}

bool HttpControlManPushTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpControlManPushTask::ParseData( "
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
    list<string> uploadUrls;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GETNEWFANSBASEINFO_MANPUSHURL].isArray() ) {
                    for (int i = 0; i < dataJson[LIVEROOM_GETNEWFANSBASEINFO_MANPUSHURL].size(); i++) {
                        Json::Value element = dataJson[LIVEROOM_GETNEWFANSBASEINFO_MANPUSHURL].get(i, Json::Value::null);
                        if (element.isString()) {
                            uploadUrls.push_back(element.asString());
                        }
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
        mpCallback->OnControlManPush(this, bParse, errnum, errmsg, uploadUrls);
    }
    
    return bParse;
}

