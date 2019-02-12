/*
 * HttpGetHangoutFriendsTask.cpp
 *
 *  Created on: 2019-1-18
 *      Author: Alex
 *        desc: 8.8.获取指定主播的Hang-out好友列表
 */

#include "HttpGetHangoutFriendsTask.h"

HttpGetHangoutFriendsTask::HttpGetHangoutFriendsTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETHANGOUTFRIENDS;
    mAnchorId = "";

}

HttpGetHangoutFriendsTask::~HttpGetHangoutFriendsTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetHangoutFriendsTask::SetCallback(IRequestGetHangoutFriendsCallback* callback) {
	mpCallback = callback;
}

void HttpGetHangoutFriendsTask::SetParam(
                                         const string& anchorId
                                  ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (anchorId.length() >  0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETHANGOUTFRIENDS_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutFriendsTask::SetParam( "
            "task : %p, "
            "anchorId : %s,"
            ")",
            this,
            anchorId.c_str()
            );
}


bool HttpGetHangoutFriendsTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetHangoutFriendsTask::ParseData( "
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
    HangoutAnchorList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].isArray() ) {
                    for (int i = 0; i < dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].size(); i++) {
                        HttpHangoutAnchorItem item;
                        Json::Value root = dataJson[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST].get(i, Json::Value::null);
                        item.Parse(root);
                        /* onlineStatus 这里的onlivestatus 离线是1， 在线是2， 所以减1*/
                        if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ONLINESTATUS].isNumeric()) {
                            item.onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ONLINESTATUS].asInt() - 1);
                        }
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
        mpCallback->OnGetHangoutFriends(this, bParse, errnum, errmsg, mAnchorId, list);
    }
    
    return bParse;
}

