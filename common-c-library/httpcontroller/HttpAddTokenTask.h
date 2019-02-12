/*
 * HttpAddTokenTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.14.添加App token
 */

#ifndef HttpAddTokenTask_H_
#define HttpAddTokenTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpAddTokenTask;

class IRequestAddTokenCallback {
public:
	virtual ~IRequestAddTokenCallback(){};
	virtual void OnAddToken(HttpAddTokenTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpAddTokenTask : public HttpRequestTask {
public:
	HttpAddTokenTask();
	virtual ~HttpAddTokenTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAddTokenCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& token,
                  const string& appId,
                  const string& deviceId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAddTokenCallback* mpCallback;

};

#endif /* HttpAddTokenTask_H_ */
