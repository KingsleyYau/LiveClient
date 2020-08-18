/*
 * HttpRemindeSendPremiumVideoKeyRequestTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.5.发送解码锁请求提醒
 */

#ifndef HttpRemindeSendPremiumVideoKeyRequestTask_H_
#define HttpRemindeSendPremiumVideoKeyRequestTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpRemindeSendPremiumVideoKeyRequestTask;

class IRequestRemindeSendPremiumVideoKeyRequestCallback {
public:
	virtual ~IRequestRemindeSendPremiumVideoKeyRequestCallback(){};
	virtual void OnRemindeSendPremiumVideoKeyRequest(HttpRemindeSendPremiumVideoKeyRequestTask* task, bool success, int errnum, const string& errmsg, const string& requestId, long long currentTime, int limitSecodns) = 0;
};
      
class HttpRemindeSendPremiumVideoKeyRequestTask : public HttpRequestTask {
public:
	HttpRemindeSendPremiumVideoKeyRequestTask();
	virtual ~HttpRemindeSendPremiumVideoKeyRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRemindeSendPremiumVideoKeyRequestCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& requestId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRemindeSendPremiumVideoKeyRequestCallback* mpCallback;
    
    string mRequestId;


};

#endif /* HttpRemindeSendPremiumVideoKeyRequestTask_H_ */
