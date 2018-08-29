/*
 * HttpGetPrivateMsgHistoryByIdTask.cpp
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.3.获取私信消息列表
 */

#include "HttpGetPrivateMsgHistoryByIdTask.h"

HttpGetPrivateMsgHistoryByIdTask::HttpGetPrivateMsgHistoryByIdTask() {
	// TODO Auto-generated constructor stub
	mPath = GETPRIVATEMESSAGEHISTORYBYID_PATH;
    
    mToId = "";
    mStartMsgId = "";
    mOrder = PRIVATEMSGORDERTYPE_UNKNOW;
    mLimit = 0;
    mReqId = -1;
}

HttpGetPrivateMsgHistoryByIdTask::~HttpGetPrivateMsgHistoryByIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpGetPrivateMsgHistoryByIdTask::SetCallback(IRequestGetPrivateMsgHistoryByIdCallback* callback) {
	mpCallback = callback;
}

void HttpGetPrivateMsgHistoryByIdTask::SetParam(
                                                const string& toId,
                                                const string& startMsgId,
                                                PrivateMsgOrderType order,
                                                int limit,
                                                int reqId
                                      ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if (toId.length() > 0) {
        mHttpEntiy.AddContent(GETPRIVATEMESSAGEHISTORYBYID_TOID, toId.c_str());
        mToId = toId;
    }
    
    if (startMsgId.length() > 0) {
        mHttpEntiy.AddContent(GETPRIVATEMESSAGEHISTORYBYID_STARTMSGID, startMsgId.c_str());
        mStartMsgId = startMsgId;
    }
    
    if (order > PRIVATEMSGORDERTYPE_BEGIN && order <= PRIVATEMSGORDERTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", order);
        mHttpEntiy.AddContent(GETPRIVATEMESSAGEHISTORYBYID_ORDER, temp);
        mOrder = order;
    }
    
    if (limit > 0) {
        snprintf(temp, sizeof(temp), "%d", limit);
        mHttpEntiy.AddContent(GETPRIVATEMESSAGEHISTORYBYID_LIMIT, temp);
        mLimit = limit;
    }
    
    mReqId = reqId;
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPrivateMsgHistoryByIdTask::SetParam( "
            "task : %p, "
            ")",
            this
            );
}

/**
 * 获取请求Id
 */
int HttpGetPrivateMsgHistoryByIdTask::GetReqId() {
    return mReqId;
}

bool HttpGetPrivateMsgHistoryByIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpGetPrivateMsgHistoryByIdTask::ParseData( "
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
    HttpPrivateMsgList list;
    long dbtime = 0;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if (dataJson.isObject()) {
                if (dataJson[GETPRIVATEMESSAGEHISTORYBYID_DBTIME].isNumeric()) {
                    dbtime = dataJson[GETPRIVATEMESSAGEHISTORYBYID_DBTIME].asInt();
                }
                
                if( dataJson[GETPRIVATEMESSAGEHISTORYBYID_LIST].isArray() ) {
                    for (int i = 0; i < dataJson[GETPRIVATEMESSAGEHISTORYBYID_LIST].size(); i++) {
                        HttpPrivateMsgItem item;
                        item.Parse(dataJson[GETPRIVATEMESSAGEHISTORYBYID_LIST].get(i, Json::Value::null));
                        list.push_back(item);
                    }
                    list.sort(HttpPrivateMsgItem::HttpSort);
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
        mpCallback->OnGetPrivateMsgHistoryById(this, bParse, errnum, errmsg, list, dbtime, mToId, mReqId);
    }
    
    return bParse;
}

