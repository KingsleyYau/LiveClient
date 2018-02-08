/*
 * HttpGetShareLinkTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 6.11.获取分享链接
 */

#include "HttpGetShareLinkTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpGetShareLinkTask::HttpGetShareLinkTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_GETSHARELINK;
    mShareuserId = "";
    mAnchorId = "";
    mShareType = SHARETYPE_OTHER;
    mSharePageType = SHAREPAGETYPE_UNKNOW;
   
}

HttpGetShareLinkTask::~HttpGetShareLinkTask() {
    // TODO Auto-generated destructor stub
}

void HttpGetShareLinkTask::SetCallback(IRequestGetShareLinkCallback* callback) {
    mpCallback = callback;
}

void HttpGetShareLinkTask::SetParam(
                                    string shareuserId,
                                    string anchorId,
                                    ShareType shareType,
                                    SharePageType sharePageType
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( shareuserId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETSHARELINK_SHAREUSERID, shareuserId.c_str());
        mShareuserId = shareuserId;
    }
    
    if( anchorId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_GETSHARELINK_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", shareType);
    mHttpEntiy.AddContent(LIVEROOM_GETSHARELINK_SHARETYPE, temp);
    mShareType = shareType;
    
    snprintf(temp, sizeof(temp), "%d", sharePageType);
    mHttpEntiy.AddContent(LIVEROOM_GETSHARELINK_SHAREPAGETYPE, temp);
    mSharePageType = sharePageType;
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetShareLinkTask::SetParam( "
            "task : %p, "
            "shareuserId : %s "
            "anchorId : %s "
            "shareType : %d"
            "sharePageType : %d"
            ")",
            this,
            shareuserId.c_str(),
            anchorId.c_str(),
            shareType,
            sharePageType
            );
}


bool HttpGetShareLinkTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetShareLinkTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpGetShareLinkTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    string shareId = "";
    string shareLink = "";
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[LIVEROOM_GETSHARELINK_SHAREID].isString()) {
                shareId = dataJson[LIVEROOM_GETSHARELINK_SHAREID].asString();
            }
            if (dataJson[LIVEROOM_GETSHARELINK_SHARELINK].isString()) {
                shareLink = dataJson[LIVEROOM_GETSHARELINK_SHARELINK].asString();
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetShareLink(this, bParse, errnum, errmsg, shareId, shareLink);
    }
    
    return bParse;
}
