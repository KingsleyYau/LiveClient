/*
 * HttpSetPrivateMsgReadedTask.h
 *
 *  Created on: 2018-7-17
 *      Author: Alex
 *        desc: 10.4.标记私信已读
 */

#ifndef HttpSetPrivateMsgReadedTask_H_
#define HttpSetPrivateMsgReadedTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPrivateMsgItem.h"

class HttpSetPrivateMsgReadedTask;

class IRequestSetPrivateMsgReadedCallback {
public:
	virtual ~IRequestSetPrivateMsgReadedCallback(){};
	virtual void OnSetPrivateMsgReaded(HttpSetPrivateMsgReadedTask* task, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) = 0;
};
      
class HttpSetPrivateMsgReadedTask : public HttpRequestTask {
public:
	HttpSetPrivateMsgReadedTask();
	virtual ~HttpSetPrivateMsgReadedTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetPrivateMsgReadedCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& toId,
                  const string& lastMsgId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetPrivateMsgReadedCallback* mpCallback;
    
    string mToId;
    string mMsgId;

};

#endif /* HttpGetPrivateMsgHistoryByIdTask_H_ */
