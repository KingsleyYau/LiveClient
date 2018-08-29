/*
 * HttpGetFollowPrivateMsgFriendListTask.cpp
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.2.获取私信Follow联系人列表
 */

#include "HttpGetFollowPrivateMsgFriendListTask.h"

HttpGetFollowPrivateMsgFriendListTask::HttpGetFollowPrivateMsgFriendListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETFOLLOWPRIVATEMSGFRIENDLIST_PATH;

}

HttpGetFollowPrivateMsgFriendListTask::~HttpGetFollowPrivateMsgFriendListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetFollowPrivateMsgFriendListTask::SetCallback(IRequestGetFollowPrivateMsgFriendListCallback* callback) {
	mpCallback = callback;
}

void HttpGetFollowPrivateMsgFriendListTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFollowPrivateMsgFriendListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetFollowPrivateMsgFriendListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFollowPrivateMsgFriendListTask::ParseData( "
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
    HttpPrivateMsgContactList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if( dataJson[GETFOLLOWPRIVATEMSGFRIENDLIST_LIST].isArray() ) {
                    for (int i = 0; i < dataJson[GETFOLLOWPRIVATEMSGFRIENDLIST_LIST].size(); i++) {
                        HttpPrivateMsgContactItem item;
                        item.Parse(dataJson[GETFOLLOWPRIVATEMSGFRIENDLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetFollowPrivateMsgFriendList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

