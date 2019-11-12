/*
 * HttpGetStoreGiftListTask.h
 *
 *  Created on: 2019-09-26
 *      Author: Alex
 *        desc: 15.1.获取鲜花礼品列表
 */

#ifndef HttpGetStoreGiftListTask_H_
#define HttpGetStoreGiftListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpStoreFlowerGiftItem.h"

class HttpGetStoreGiftListTask;

class IRequestGetStoreGiftListCallback {
public:
	virtual ~IRequestGetStoreGiftListCallback(){};
	virtual void OnGetStoreGiftList(HttpGetStoreGiftListTask* task, bool success, int errnum, const string& errmsg, const StoreFlowerGiftList& list) = 0;
};
      
class HttpGetStoreGiftListTask : public HttpRequestTask {
public:
	HttpGetStoreGiftListTask();
	virtual ~HttpGetStoreGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetStoreGiftListCallback* pCallback);

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
	IRequestGetStoreGiftListCallback* mpCallback;

};

#endif /* HttpGetStoreGiftListTask_H_ */
