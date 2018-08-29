/*
 * HttpGetPrivateMsgFriendListTask.cpp
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.1.获取私信联系人列表
 */

#include "HttpGetPrivateMsgFriendListTask.h"

HttpGetPrivateMsgFriendListTask::HttpGetPrivateMsgFriendListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETPRIVATEMSGFRIENDLIST_PATH;

}

HttpGetPrivateMsgFriendListTask::~HttpGetPrivateMsgFriendListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPrivateMsgFriendListTask::SetCallback(IRequestGetPrivateMsgFriendListCallback* callback) {
	mpCallback = callback;
}

void HttpGetPrivateMsgFriendListTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPrivateMsgFriendListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetPrivateMsgFriendListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPrivateMsgFriendListTask::ParseData( "
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
    long dbtime = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if(dataJson[GETPRIVATEMSGFRIENDLIST_DBTIME].isNumeric()) {
                    dbtime = dataJson[GETPRIVATEMSGFRIENDLIST_DBTIME].asInt();
                }
                if( dataJson[GETPRIVATEMSGFRIENDLIST_LIST].isArray() ) {
                    for (int i = 0; i < dataJson[GETPRIVATEMSGFRIENDLIST_LIST].size(); i++) {
                        HttpPrivateMsgContactItem item;
                        item.Parse(dataJson[GETPRIVATEMSGFRIENDLIST_LIST].get(i, Json::Value::null));
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
        mpCallback->OnGetPrivateMsgFriendList(this, bParse, errnum, errmsg, list, dbtime);
    }
    
    return bParse;
}

