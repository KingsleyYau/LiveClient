/*
 * HttpGetPremiumVideoTypeListTask.cpp
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.1.获取付费视频分类列表
 */

#include "HttpGetPremiumVideoTypeListTask.h"

HttpGetPremiumVideoTypeListTask::HttpGetPremiumVideoTypeListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PREMIUMVIDEO_GETTYPELIST_PATH;

}

HttpGetPremiumVideoTypeListTask::~HttpGetPremiumVideoTypeListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPremiumVideoTypeListTask::SetCallback(IRequestGetPremiumVideoTypeListCallback* callback) {
	mpCallback = callback;
}

void HttpGetPremiumVideoTypeListTask::SetParam(
                                          ) {

    //char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoTypeListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpGetPremiumVideoTypeListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPremiumVideoTypeListTask::ParseData( "
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
    PremiumVideoTypeList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            
            if(dataJson.isArray()) {
                int i = 0;
                for (i = 0; i < dataJson.size(); i++) {
                    HttpPremiumVideoTypeItem item;
                    item.Parse(dataJson.get(i, Json::Value::null));
                    list.push_back(item);
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
        mpCallback->OnGetPremiumVideoTypeList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

