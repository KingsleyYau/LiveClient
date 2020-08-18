/*
 * HttpGetPostStampsPriceListTask.cpp
 *
 *  Created on: 2020-6-29
 *      Author: Alex
 *        desc: 7.9.获取我司邮票产品列表
 */

#include "HttpGetPostStampsPriceListTask.h"

HttpGetPostStampsPriceListTask::HttpGetPostStampsPriceListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETPOSTSTAMPSPRICELIST_PATH;
}

HttpGetPostStampsPriceListTask::~HttpGetPostStampsPriceListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPostStampsPriceListTask::SetCallback(IRequestGetPostStampsPriceListCallback* callback) {
	mpCallback = callback;
}

void HttpGetPostStampsPriceListTask::SetParam(
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPostStampsPriceListTask::SetParam( "
            "task : %p"
            ")",
            this
            );
}

bool HttpGetPostStampsPriceListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPostStampsPriceListTask::ParseData( "
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
    PostStampsPriceList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
        //ParseLiveCommon(buf, size, errnum, errmsg, &dataJson);
            if (dataJson.isArray()) {
                int i = 0;
                for ( i = 0; i < dataJson.size(); i++) {
                    HttpPostStampsPriceItem item;
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
        mpCallback->OnGetPostStampsPriceList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

