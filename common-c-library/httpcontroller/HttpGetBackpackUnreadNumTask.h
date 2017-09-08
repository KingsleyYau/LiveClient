/*
 * HttpGetBackpackUnreadNumTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.5.获取背包未读数量
 */

#ifndef HttpGetBackpackUnreadNumTask_H_
#define HttpGetBackpackUnreadNumTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGetBackPackUnreadNumItem.h"

class HttpGetBackpackUnreadNumTask;

class IRequestGetBackpackUnreadNumCallback {
public:
	virtual ~IRequestGetBackpackUnreadNumCallback(){};
	virtual void OnGetBackpackUnreadNum(HttpGetBackpackUnreadNumTask* task, bool success, int errnum, const string& errmsg, const HttpGetBackPackUnreadNumItem& item) = 0;
};
      
class HttpGetBackpackUnreadNumTask : public HttpRequestTask {
public:
	HttpGetBackpackUnreadNumTask();
	virtual ~HttpGetBackpackUnreadNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetBackpackUnreadNumCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetBackpackUnreadNumCallback* mpCallback;

};

#endif /* HttpGetBackpackUnreadNumTask_H_ */
