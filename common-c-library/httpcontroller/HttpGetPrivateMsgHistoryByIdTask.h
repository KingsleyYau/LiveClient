/*
 * HttpGetPrivateMsgHistoryByIdTask.h
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.3.获取私信消息列表
 */

#ifndef HttpGetPrivateMsgHistoryByIdTask_H_
#define HttpGetPrivateMsgHistoryByIdTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPrivateMsgItem.h"

class HttpGetPrivateMsgHistoryByIdTask;

class IRequestGetPrivateMsgHistoryByIdCallback {
public:
	virtual ~IRequestGetPrivateMsgHistoryByIdCallback(){};
	virtual void OnGetPrivateMsgHistoryById(HttpGetPrivateMsgHistoryByIdTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgList& list, const long dbtime, const string& userId, int reqId) = 0;
};
      
class HttpGetPrivateMsgHistoryByIdTask : public HttpRequestTask {
public:
	HttpGetPrivateMsgHistoryByIdTask();
	virtual ~HttpGetPrivateMsgHistoryByIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPrivateMsgHistoryByIdCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& toId,
                  const string& startMsgId,
                  PrivateMsgOrderType order,
                  int limit,
                  int reqId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
    /**
     * 获取用户ID
     */
    const string& GetToId();
    /**
     * 获取请求Id
     */
    int GetReqId();
    
protected:
	IRequestGetPrivateMsgHistoryByIdCallback* mpCallback;
    
    string mToId;
    string mStartMsgId;
    PrivateMsgOrderType mOrder;
    int mLimit;
    int mReqId;
};

#endif /* HttpGetPrivateMsgHistoryByIdTask_H_ */
