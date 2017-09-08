/*
 * HttpGetLeftCreditTask.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 6.2.获取账号余额
 */

#ifndef HttpGetLeftCreditTask_H_
#define HttpGetLeftCreditTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpGetLeftCreditTask;

class IRequestGetLeftCreditCallback {
public:
	virtual ~IRequestGetLeftCreditCallback(){};
	virtual void OnGetLeftCredit(HttpGetLeftCreditTask* task, bool success, int errnum, const string& errmsg, double credit) = 0;
};
      
class HttpGetLeftCreditTask : public HttpRequestTask {
public:
	HttpGetLeftCreditTask();
	virtual ~HttpGetLeftCreditTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLeftCreditCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLeftCreditCallback* mpCallback;

};

#endif /* HttpGetLeftCreditTask_H_ */
