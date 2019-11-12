/*
 * HttpWomanListAdvertTask.cpp
 *
 *  Created on: 2019-10-08
 *      Author: Alex
 *        desc: 9.2.查询女士列表广告
 */

#include "HttpWomanListAdvertTask.h"

HttpWomanListAdvertTask::HttpWomanListAdvertTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ADVERT_WOMANLISTADVERT_PATH;
    
}

HttpWomanListAdvertTask::~HttpWomanListAdvertTask() {
	// TODO Auto-generated destructor stub
}

void HttpWomanListAdvertTask::SetCallback(IRequestWomanListAdvertCallback* callback) {
	mpCallback = callback;
}

void HttpWomanListAdvertTask::SetParam(
                                       const string& deviceId,
                                       LSAdvertSpaceType adspaceId
                                          ) {
	char temp[16];
    mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (deviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_ADVERT_WOMANLISTADVERT_DEVICEID, deviceId.c_str());
    }
    
    if (adspaceId > LSAD_SPACE_TYPE_BEGIN && adspaceId <= LSAD_SPACE_TYPE_END) {
        sprintf(temp, "%d", GetLSAdvertSpaceTypeToInt(adspaceId));
        mHttpEntiy.AddContent(LIVEROOM_ADVERT_WOMANLISTADVERT_ADSPACEID, temp);
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpWomanListAdvertTask::SetParam( "
            "task : %p, "
            "deviceId : %s, "
            "adspaceId : %d "
            ")",
            this,
            deviceId.c_str(),
            adspaceId
            );
}


bool HttpWomanListAdvertTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpWomanListAdvertTask::ParseData( "
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
    HttpAdWomanListAdvertItem advertItem;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            advertItem.Parse(dataJson);
        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnWomanListAdvert(this, bParse, errnum, errmsg, advertItem);
    }
    
    return bParse;
}

