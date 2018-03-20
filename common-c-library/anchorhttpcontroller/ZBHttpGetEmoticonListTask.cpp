/*
 *  ZBHttpGetEmoticonListTask.cpp
 *
 *  Created on: 2018-2-286
 *      Author: Alex
 *        desc: 3.6.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）
 */

#include "ZBHttpGetEmoticonListTask.h"

ZBHttpGetEmoticonListTask::ZBHttpGetEmoticonListTask() {
	// TODO Auto-generated constructor stub
	mPath = GETEMOTICONLIST_PATH;

}

ZBHttpGetEmoticonListTask::~ZBHttpGetEmoticonListTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpGetEmoticonListTask::SetCallback(IRequestZBGetEmoticonListCallback* callback) {
	mpCallback = callback;
}

void ZBHttpGetEmoticonListTask::SetParam(
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetEmoticonListTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}


bool ZBHttpGetEmoticonListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpGetEmoticonListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "ZBHttpGetEmoticonListTask::ParseData( buf : %s )", buf);
    }
    
    ZBEmoticonItemList itemList;
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if(dataJson.isObject()) {
                if( dataJson[GETEMOTICONLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[GETEMOTICONLIST_LIST].size(); i++) {
                        ZBHttpEmoticonItem item;
                        item.Parse(dataJson[GETEMOTICONLIST_LIST].get(i, Json::Value::null));
                        itemList.push_back(item);
                    }
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
        mpCallback->OnZBGetEmoticonList(this, bParse, errnum, errmsg, itemList);
    }
    
    return bParse;
}
