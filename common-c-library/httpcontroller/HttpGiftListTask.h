/*
 * HttpGiftListTask.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 5.1.获取背包礼物列表
 */

#ifndef HttpGiftListTask_H_
#define HttpGiftListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpBackGiftItem.h"

class HttpGiftListTask;

class IRequestGiftListCallback {
public:
	virtual ~IRequestGiftListCallback(){};
	virtual void OnGiftList(HttpGiftListTask* task, bool success, int errnum, const string& errmsg, const BackGiftItemList& list, int totalCount) = 0;
};
      
class HttpGiftListTask : public HttpRequestTask {
public:
	HttpGiftListTask();
	virtual ~HttpGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGiftListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGiftListCallback* mpCallback;

};

#endif /* HttpGiftListTask_H_ */
