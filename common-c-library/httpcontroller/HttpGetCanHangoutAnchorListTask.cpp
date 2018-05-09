/*
 * HttpGetCanHangoutAnchorListTask.cpp
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *        desc: 8.1.获取可邀请多人互动的主播列表
 */

#include "HttpGetCanHangoutAnchorListTask.h"

HttpGetCanHangoutAnchorListTask::HttpGetCanHangoutAnchorListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCANHANGOUTANCHORLIST;
    mType = HANGOUTANCHORLISTTYPE_UNKNOW;
    mAnchorId = "";
    mStart = 0;
    mStep = 0;
}

HttpGetCanHangoutAnchorListTask::~HttpGetCanHangoutAnchorListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetCanHangoutAnchorListTask::SetCallback(IRequestGetCanHangoutAnchorListCallback* callback) {
	mpCallback = callback;
}

void HttpGetCanHangoutAnchorListTask::SetParam(
                                               HangoutAnchorListType type,
                                               const string& anchorId,
                                               int start,
                                               int step
                                          ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    snprintf(temp, sizeof(temp), "%d", type);
    mHttpEntiy.AddContent(LIVEROOM_GETCANHANGOUTANCHORLIST_TYPE, temp);
    mType = type;
    
    if( anchorId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETCANHANGOUTANCHORLIST_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(LIVEROOM_GETCANHANGOUTANCHORLIST_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(LIVEROOM_GETCANHANGOUTANCHORLIST_STEP, temp);
    mStep = step;


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCanHangoutAnchorListTask::SetParam( "
            "task : %p, "
            "type : %d,"
            "anchorId : %s,"
            "start : %d,"
            "step : %d"
            ")",
            this,
            type,
            anchorId.c_str(),
            start,
            step
            );
}

bool HttpGetCanHangoutAnchorListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetCanHangoutAnchorListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetCanHangoutAnchorListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HangoutAnchorList list;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].isArray() ) {
                    for (int i = 0; i < dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].size(); i++) {
                        HttpHangoutAnchorItem item;
                        item.Parse(dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetCanHangoutAnchorList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

