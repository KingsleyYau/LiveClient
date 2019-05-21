/*
 * HttpSayHiDetailTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.7.获取SayHi详情
 */

#ifndef HttpSayHiDetailTask_H_
#define HttpSayHiDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpSayHiDetailItem.h"
#include "HttpRequestEnum.h"

class HttpSayHiDetailTask;

class IRequestSayHiDetailCallback {
public:
	virtual ~IRequestSayHiDetailCallback(){};
	virtual void OnSayHiDetail(HttpSayHiDetailTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem& item) = 0;
};
      
class HttpSayHiDetailTask : public HttpRequestTask {
public:
	HttpSayHiDetailTask();
	virtual ~HttpSayHiDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSayHiDetailCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSSayHiDetailType type,
                    const string& sayHiId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSayHiDetailCallback* mpCallback;
};

#endif /* HttpSayHiDetailTask_H_ */
