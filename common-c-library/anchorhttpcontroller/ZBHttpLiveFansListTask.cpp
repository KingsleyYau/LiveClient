/*
 * ZBHttpLiveFansListTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.1.获取直播间观众列表
 */

#include "ZBHttpLiveFansListTask.h"


ZBHttpLiveFansListTask::ZBHttpLiveFansListTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEFANSLIST_PATH;
    mLiveRoomId = "";
    mStart = 0;
    mStep = 0;
}

ZBHttpLiveFansListTask::~ZBHttpLiveFansListTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpLiveFansListTask::SetCallback(IRequestZBLiveFansListCallback* callback) {
	mpCallback = callback;
}

void ZBHttpLiveFansListTask::SetParam(
                                      string liveRoomId,
                                      int start,
                                      int step
                                      ) {
    char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    if( liveRoomId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEFANSLIST_LIVEROOM_ID, liveRoomId.c_str());
        mLiveRoomId = liveRoomId;
    }
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEFANSLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEFANSLIST_STEP, temp);
    mStep = step;
    
    
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpLiveFansListTask::SetParam( "
            "task : %p, "
            "liveRoomId : %s, "
            "start:%d,"
            "step:%d "
            ")",
            this,
            liveRoomId.c_str(),
            start,
            step
            );
}


bool ZBHttpLiveFansListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpLiveFansListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpLiveFansListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    ZBHttpLiveFansList itemList;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[COMMON_LIST].isArray()) {
                    int i = 0;
                    for (i = 0; i < dataJson[COMMON_LIST].size(); i++) {
                        ZBHttpLiveFansItem item;
                        item.Parse(dataJson[COMMON_LIST].get(i, Json::Value::null));
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
        mpCallback->OnZBLiveFansList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
