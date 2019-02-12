/*
 * HttpDestroyTokenTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.15.销毁App token
 */

#ifndef HttpDestroyTokenTask_H_
#define HttpDestroyTokenTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpDestroyTokenTask;

class IRequestDestroyTokenCallback {
public:
	virtual ~IRequestDestroyTokenCallback(){};
	virtual void OnDestroyToken(HttpDestroyTokenTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpDestroyTokenTask : public HttpRequestTask {
public:
	HttpDestroyTokenTask();
	virtual ~HttpDestroyTokenTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDestroyTokenCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestDestroyTokenCallback* mpCallback;

};

#endif /* HttpDestroyTokenTask_H_ */
