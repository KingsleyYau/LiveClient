/*
 * HttpCreateGiftOrderTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.12.生成订单
 */

#ifndef HttpCreateGiftOrderTask_H_
#define HttpCreateGiftOrderTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpCreateGiftOrderTask;

class IRequestCreateGiftOrderCallback {
public:
	virtual ~IRequestCreateGiftOrderCallback(){};
	virtual void OnCreateGiftOrder(HttpCreateGiftOrderTask* task, bool success, int errnum, const string& errmsg, const string& orderNumber) = 0;
};
      
class HttpCreateGiftOrderTask : public HttpRequestTask {
public:
	HttpCreateGiftOrderTask();
	virtual ~HttpCreateGiftOrderTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCreateGiftOrderCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& anchorId,
                   const string& greetingMessage,
                   const string& specialDeliveryRequest
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestCreateGiftOrderCallback* mpCallback;

};

#endif /* HttpCreateGiftOrderTask_H_ */
