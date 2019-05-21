/*
 * HttpIsCanSendSayHiTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.3.检测能否对指定主播发送SayHi
 */

#ifndef HttpIsCanSendSayHiTask_H_
#define HttpIsCanSendSayHiTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpIsCanSendSayHiTask;

class IRequestIsCanSendSayHiCallback {
public:
	virtual ~IRequestIsCanSendSayHiCallback(){};
	virtual void OnIsCanSendSayHi(HttpIsCanSendSayHiTask* task, bool success, int errnum, const string& errmsg, bool isCanSend) = 0;
};
      
class HttpIsCanSendSayHiTask : public HttpRequestTask {
public:
	HttpIsCanSendSayHiTask();
	virtual ~HttpIsCanSendSayHiTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestIsCanSendSayHiCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& anchorId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestIsCanSendSayHiCallback* mpCallback;

};

#endif /* HttpIsCanSendSayHiTask_H_ */
