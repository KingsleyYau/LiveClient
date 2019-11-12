/*
 * HttpGetCartGiftListTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.7.获取购物车My cart列表
 */

#ifndef HttpGetCartGiftListTask_H_
#define HttpGetCartGiftListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpMyCartItem.h"

class HttpGetCartGiftListTask;

class IRequestGetCartGiftListCallback {
public:
	virtual ~IRequestGetCartGiftListCallback(){};
	virtual void OnGetCartGiftList(HttpGetCartGiftListTask* task, bool success, int errnum, const string& errmsg, int total, const MyCartItemList& list) = 0;
};
      
class HttpGetCartGiftListTask : public HttpRequestTask {
public:
	HttpGetCartGiftListTask();
	virtual ~HttpGetCartGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCartGiftListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    int start,
                    int step
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCartGiftListCallback* mpCallback;

};

#endif /* HttpGetCartGiftListTask_H_ */
