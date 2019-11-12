/*
 * HttpGetFlowerGiftDetailTask.h
 *
 *  Created on: 2019-09-27
 *      Author: Alex
 *        desc: 15.2.获取鲜花礼品详情
 */

#ifndef HttpGetFlowerGiftDetailTask_H_
#define HttpGetFlowerGiftDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpFlowerGiftItem.h"

class HttpGetFlowerGiftDetailTask;

class IRequestGetFlowerGiftDetailCallback {
public:
	virtual ~IRequestGetFlowerGiftDetailCallback(){};
	virtual void OnGetFlowerGiftDetail(HttpGetFlowerGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpFlowerGiftItem& item) = 0;
};
      
class HttpGetFlowerGiftDetailTask : public HttpRequestTask {
public:
	HttpGetFlowerGiftDetailTask();
	virtual ~HttpGetFlowerGiftDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetFlowerGiftDetailCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& giftId
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetFlowerGiftDetailCallback* mpCallback;

};

#endif /* HttpGetFlowerGiftDetailTask_H_ */
