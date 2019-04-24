/*
 * HttpReadResponseTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.8.查看主播回复(扣费)
 */

#ifndef HttpReadResponseTask_H_
#define HttpReadResponseTask_H_

#include "HttpRequestTask.h"
#include "item/HttpSayHiDetailItem.h"

class HttpReadResponseTask;

class IRequestReadResponseCallback {
public:
	virtual ~IRequestReadResponseCallback(){};
    virtual void OnReadResponse(HttpReadResponseTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiDetailItem::ResponseSayHiDetailItem& responseItem) = 0;
};
      
class HttpReadResponseTask : public HttpRequestTask {
public:
	HttpReadResponseTask();
	virtual ~HttpReadResponseTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestReadResponseCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& sayHiId,
                    const string& responseId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestReadResponseCallback* mpCallback;

};

#endif /* HttpReadResponseTask_H_ */
