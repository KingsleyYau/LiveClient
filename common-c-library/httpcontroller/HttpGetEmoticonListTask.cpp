/*
 *  HttpGetEmoticonListTask.cpp
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）
 */

#include "HttpGetEmoticonListTask.h"

HttpGetEmoticonListTask::HttpGetEmoticonListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETEMOTICONLIST;

}

HttpGetEmoticonListTask::~HttpGetEmoticonListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetEmoticonListTask::SetCallback(IRequestGetEmoticonListCallback* callback) {
	mpCallback = callback;
}

void HttpGetEmoticonListTask::SetParam(
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog("httpcontroller",
            "HttpGetEmoticonListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool HttpGetEmoticonListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpGetEmoticonListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpGetEmoticonListTask::ParseData( buf : %s )", buf);
    }
    
    EmoticonItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_EMOTICON_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_EMOTICON_LIST].size(); i++) {
                        HttpEmoticonItem item;
                        item.Parse(dataJson[LIVEROOM_EMOTICON_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
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
        mpCallback->OnGetEmoticonList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
