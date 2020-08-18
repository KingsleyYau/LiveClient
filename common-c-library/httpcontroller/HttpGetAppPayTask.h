/*
 * HttpGetAppPayTask.h
 *
 *  Created on: 2019-12-6
 *      Author: Alex
 *        desc: 16.1.获取我司订单号（仅Android）
 */

#ifndef HttpGetAppPayTask_H_
#define HttpGetAppPayTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpGooglePayOrderItem.h"

class HttpGetAppPayTask;

class IRequestGetAppPayCallback {
public:
	virtual ~IRequestGetAppPayCallback(){};
	virtual void OnGetAppPay(HttpGetAppPayTask* task, bool success, const string& code, const string& errmsg, const HttpGooglePayOrderItem& item) = 0;
};
      
class HttpGetAppPayTask : public HttpRequestTask {
public:
	HttpGetAppPayTask();
	virtual ~HttpGetAppPayTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAppPayCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string number
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAppPayCallback* mpCallback;

};

#endif /* HttpGetAppPayTask_H_ */
