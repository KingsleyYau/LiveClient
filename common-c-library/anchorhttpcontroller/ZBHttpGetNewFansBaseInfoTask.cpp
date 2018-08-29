/*
 * ZBHttpGetNewFansBaseInfoTask.cpp
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.2.获取指定观众信息
 */

#include "ZBHttpGetNewFansBaseInfoTask.h"

ZBHttpGetNewFansBaseInfoTask::ZBHttpGetNewFansBaseInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = GETNEWFANSBASEINFO_PATH;
    mUserId = "";
}

ZBHttpGetNewFansBaseInfoTask::~ZBHttpGetNewFansBaseInfoTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetNewFansBaseInfoTask::SetCallback(IRequestZBGetNewFansBaseInfoCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetNewFansBaseInfoTask::SetParam(
                                   const string& userId
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( userId.length() > 0 ) {
        mHttpEntiy.AddContent(GETNEWFANSBASEINFO_USERID, userId.c_str());
        mUserId = userId;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetNewFansBaseInfoTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

const string& ZBHttpGetNewFansBaseInfoTask::GetUserId() {
    return mUserId;
}

bool ZBHttpGetNewFansBaseInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetNewFansBaseInfoTask::ParseData( "
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
    ZBHttpLiveFansInfoItem item;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    item.userId = mUserId;

    if( mpCallback != NULL ) {
        mpCallback->OnZBGetNewFansBaseInfo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

