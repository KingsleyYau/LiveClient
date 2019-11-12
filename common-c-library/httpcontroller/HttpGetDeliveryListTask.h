/*
 * HttpGetDeliveryListTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.5.获取My delivery列表
 */

#ifndef HttpGetDeliveryListTask_H_
#define HttpGetDeliveryListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpMyDeliveryItem.h"

class HttpGetDeliveryListTask;

class IRequestGetDeliveryListCallback {
public:
	virtual ~IRequestGetDeliveryListCallback(){};
	virtual void OnGetDeliveryList(HttpGetDeliveryListTask* task, bool success, int errnum, const string& errmsg, const DeliveryList& list) = 0;
};
      
class HttpGetDeliveryListTask : public HttpRequestTask {
public:
	HttpGetDeliveryListTask();
	virtual ~HttpGetDeliveryListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetDeliveryListCallback* pCallback);

    /**
     *
     */
    void SetParam(

                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetDeliveryListCallback* mpCallback;

};

#endif /* HttpGetDeliveryListTask_H_ */
