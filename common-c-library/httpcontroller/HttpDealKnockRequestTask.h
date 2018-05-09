/*
 * HttpDealKnockRequestTask.h
 *
 *  Created on: 2018-4-13
 *      Author: Alex
 *        desc: 8.5.同意主播敲门请求
 */

#ifndef HttpDealKnockRequestTask_H_
#define HttpDealKnockRequestTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpDealKnockRequestTask;

class IRequestDealKnockRequestCallback {
public:
	virtual ~IRequestDealKnockRequestCallback(){};
	virtual void OnDealKnockRequest(HttpDealKnockRequestTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpDealKnockRequestTask : public HttpRequestTask {
public:
	HttpDealKnockRequestTask();
	virtual ~HttpDealKnockRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDealKnockRequestCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& knockId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestDealKnockRequestCallback* mpCallback;
   
    string mKnockId;         // 敲门ID

};

#endif /* HttpDealKnockRequestTask_H_ */
