/*
 * HttpCheckDiscountTask.h
 *
 *  Created on: 2019-11-29
 *      Author: Alex
 *        desc: 15.13.检测优惠折扣
 */

#ifndef HttpCheckDiscountTask_H_
#define HttpCheckDiscountTask_H_

#include "HttpRequestTask.h"
#include "item/HttpCheckDiscountItem.h"

class HttpCheckDiscountTask;

class IRequestCheckDiscountCallback {
public:
	virtual ~IRequestCheckDiscountCallback(){};
	virtual void OnCheckDiscount(HttpCheckDiscountTask* task, bool success, int errnum, const string& errmsg, const HttpCheckDiscountItem& item) = 0;
};
      
class HttpCheckDiscountTask : public HttpRequestTask {
public:
	HttpCheckDiscountTask();
	virtual ~HttpCheckDiscountTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCheckDiscountCallback* pCallback);

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
	IRequestCheckDiscountCallback* mpCallback;

};

#endif /* HttpCheckDiscountTask_H_ */
