/*
 * HttpCheckOutCartGiftTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.11.Checkout商品
 */

#ifndef HttpCheckOutCartGiftTask_H_
#define HttpCheckOutCartGiftTask_H_

#include "HttpRequestTask.h"
#include "item/HttpCheckoutItem.h"

class HttpCheckOutCartGiftTask;

class IRequestCheckOutCartGiftCallback {
public:
	virtual ~IRequestCheckOutCartGiftCallback(){};
	virtual void OnCheckOutCartGift(HttpCheckOutCartGiftTask* task, bool success, int errnum, const string& errmsg, const HttpCheckoutItem& item) = 0;
};
      
class HttpCheckOutCartGiftTask : public HttpRequestTask {
public:
	HttpCheckOutCartGiftTask();
	virtual ~HttpCheckOutCartGiftTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCheckOutCartGiftCallback* pCallback);

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
	IRequestCheckOutCartGiftCallback* mpCallback;

};

#endif /* HttpCheckOutCartGiftTask_H_ */
