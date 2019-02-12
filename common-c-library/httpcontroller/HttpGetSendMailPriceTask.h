/*
 * HttpGetSendMailPriceTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.8.获取发送信件所需的余额
 */

#ifndef HttpGetSendMailPriceTask_H_
#define HttpGetSendMailPriceTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetSendMailPriceTask;

class IRequestGetSendMailPriceCallback {
public:
	virtual ~IRequestGetSendMailPriceCallback(){};
	virtual void OnGetSendMailPrice(HttpGetSendMailPriceTask* task, bool success, int errnum, const string& errmsg, double creditPrice, double stampPrice) = 0;
};
      
class HttpGetSendMailPriceTask : public HttpRequestTask {
public:
	HttpGetSendMailPriceTask();
	virtual ~HttpGetSendMailPriceTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetSendMailPriceCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int imgNumber
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetSendMailPriceCallback* mpCallback;

};

#endif /* HttpGetSendMailPriceTask_H_ */
