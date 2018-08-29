/*
 * HttpGetFriendRelationTask.cpp
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *        desc: 6.10.获取好友关系信息
 */

#include "HttpGetFriendRelationTask.h"

HttpGetFriendRelationTask::HttpGetFriendRelationTask() {
	// TODO Auto-generated constructor stub
	mPath = HANGOUTGETFRIENDRELATION_PATH;
    mAnchorId = "";
}

HttpGetFriendRelationTask::~HttpGetFriendRelationTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetFriendRelationTask::SetCallback(IRequestGetFriendRelationCallback* callback) {
	mpCallback = callback;
}

void HttpGetFriendRelationTask::SetParam(
                                       const string& anchorId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(HANGOUTGETFRIENDRELATION_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFriendRelationTask::SetParam( "
            "task : %p, "
            "anchorId : %s ,"
            ")",
            this,
            anchorId.c_str()
            );
}

bool HttpGetFriendRelationTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetFriendRelationTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
//    if ( bFlag && size < MAX_LOG_BUFFER ) {
//        FileLog(LIVESHOW_HTTP_LOG, "HttpGetFriendRelationTask::ParseData( buf : %s )", buf);
//    }
//

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpAnchorFriendItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
            item.anchorId = mAnchorId;
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetFriendRelation(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

