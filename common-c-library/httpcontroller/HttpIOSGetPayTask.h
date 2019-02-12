/*
 * HttpIOSGetPayTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.4.获取订单信息（仅iOS）
 */

#ifndef HttpIOSGetPayTask_H_
#define HttpIOSGetPayTask_H_

#include "HttpRequestTask.h"
#include "item/HttpOrderProductItem.h"

class HttpIOSGetPayTask;

class IRequestIOSGetPayCallback {
public:
	virtual ~IRequestIOSGetPayCallback(){};
	virtual void OnIOSGetPay(HttpIOSGetPayTask* task, bool success, const string& code, const string& orderNo, const string& productId) = 0;
};
      
class HttpIOSGetPayTask : public HttpRequestTask {
public:
	HttpIOSGetPayTask();
	virtual ~HttpIOSGetPayTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestIOSGetPayCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string manid,
                  string sid,
                  string number
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestIOSGetPayCallback* mpCallback;

};

#endif /* HttpIOSGetPayTask_H_ */
