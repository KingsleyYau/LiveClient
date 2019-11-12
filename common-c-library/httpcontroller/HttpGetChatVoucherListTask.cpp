/*
 * HttpGetChatVoucherListTask.cpp
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.7.获取LiveChat聊天试用券列表
 */

#include "HttpGetChatVoucherListTask.h"

HttpGetChatVoucherListTask::HttpGetChatVoucherListTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_GETCHATVOUCHERLIST;
}

HttpGetChatVoucherListTask::~HttpGetChatVoucherListTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetChatVoucherListTask::SetCallback(IRequestGetChatVoucherListCallback* callback) {
	mpCallback = callback;
}

void HttpGetChatVoucherListTask::SetParam(
                                          int start,
                                          int step
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
                                              
   char temp[16];
   
   snprintf(temp, sizeof(temp), "%d", start);
   mHttpEntiy.AddContent(LIVEROOM_GETCHATVOUCHERLIST_START, temp);

                                              
  snprintf(temp, sizeof(temp), "%d", step);
  mHttpEntiy.AddContent(LIVEROOM_GETCHATVOUCHERLIST_STEP, temp);


    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetChatVoucherListTask::SetParam( "
            "task : %p, "
            "start : %d ,"
            "step : %d ,"
            ")",
            this,
            start,
            step
            );
}

bool HttpGetChatVoucherListTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpVoucherListTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    VoucherList list;
    int totalCount = 0;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        //if( ParseCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = ParseLiveChatVoucherCommon(buf, size, errnum, errmsg, &dataJson);
            if(dataJson.isObject()) {
                if( dataJson[LIVEROOM_GETCHATVOUCHERLIST_LIST].isArray() ) {
                    int i = 0;
                    for (i = 0; i < dataJson[LIVEROOM_GETCHATVOUCHERLIST_LIST].size(); i++) {
                        HttpVoucherItem item;
                        item.ParseLiveChat(dataJson[LIVEROOM_GETCHATVOUCHERLIST_LIST].get(i, Json::Value::null));
                        list.push_back(item);
                    }
                }
                if (dataJson[LIVEROOM_GETCHATVOUCHERLIST_TOTAL].isNumeric()) {
                    totalCount = dataJson[LIVEROOM_GETCHATVOUCHERLIST_TOTAL].asInt();
                }
            }
            

        //}
        
        //bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnGetChatVoucherList(this, bParse, errnum, errmsg, list, totalCount);
    }
    
    return bParse;
}

