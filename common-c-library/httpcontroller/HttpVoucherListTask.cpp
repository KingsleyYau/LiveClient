/*
 * HttpVoucherListTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.2.获取使用劵列表
 */

#include "HttpVoucherListTask.h"

HttpVoucherListTask::HttpVoucherListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_VOUCHERLIST;
}

HttpVoucherListTask::~HttpVoucherListTask() {
	// TODO Auto-generated destructor stub
}

void HttpVoucherListTask::SetCallback(IRequestVoucherListCallback* callback) {
	mpCallback = callback;
}

void HttpVoucherListTask::SetParam(
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog("httpcontroller",
            "HttpVoucherListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

bool HttpVoucherListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpVoucherListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpVoucherListTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    VoucherList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_VOUCHERLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_VOUCHERLIST_LIST].size(); i++) {
                        HttpVoucherItem item;
                        item.Parse(dataJson[LIVEROOM_VOUCHERLIST_LIST].get(i, Json::Value::null));
                        list.push_back(item);
                    }
                }
            }
            

        }
        
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnVoucherList(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

