/*
 * HttpAnchorRecommendFriendJoinHangoutTask.cpp
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.2.主播推荐好友给观众
 */

#include "HttpAnchorRecommendFriendJoinHangoutTask.h"

HttpAnchorRecommendFriendJoinHangoutTask::HttpAnchorRecommendFriendJoinHangoutTask() {
	// TODO Auto-generated constructor stub
	mPath = RECOMMENDFRIENDJOINHANGOUT_PATH;
    mFriendId = "";
    mRoomId = "";
}

HttpAnchorRecommendFriendJoinHangoutTask::~HttpAnchorRecommendFriendJoinHangoutTask() {
	// TODO Auto-generated destructor stub
}

void HttpAnchorRecommendFriendJoinHangoutTask::SetCallback(IRequestAnchorRecommendFriendJoinHangoutCallback* callback) {
	mpCallback = callback;
}

void HttpAnchorRecommendFriendJoinHangoutTask::SetParam(
                                                        const string& friendId,
                                                        const string& roomId
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (friendId.length() > 0) {
        mHttpEntiy.AddContent(RECOMMENDFRIENDJOINHANGOUT_FRIENDID, friendId.c_str());
        mFriendId = friendId;
    }
    
    if (roomId.length() > 0) {
        mHttpEntiy.AddContent(RECOMMENDFRIENDJOINHANGOUT_ROOMID, roomId.c_str());
        mRoomId = roomId;
    }
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorRecommendFriendJoinHangoutTask::SetParam( "
            "task : %p, "
            "friendId : %s ,"
            "roomId : %s"
            ")",
            this,
            friendId.c_str(),
            roomId.c_str()
            );
}

bool HttpAnchorRecommendFriendJoinHangoutTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAnchorRecommendFriendJoinHangoutTask::ParseData( "
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
    string recommendId = "";
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            
            if (dataJson.isObject()) {
                
                if (dataJson[RECOMMENDFRIENDJOINHANGOUT_RECOMMENDID].isString()) {
                    recommendId = dataJson[RECOMMENDFRIENDJOINHANGOUT_RECOMMENDID].asString();
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
        mpCallback->OnAnchorRecommendFriend(this, bParse, errnum, errmsg, recommendId);
    }
    
    return bParse;
}

