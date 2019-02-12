/*
 * HttpFindPasswordTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.16.找回密码
 */

#ifndef HttpFindPasswordTask_H_
#define HttpFindPasswordTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpFindPasswordTask;

class IRequestFindPasswordCallback {
public:
	virtual ~IRequestFindPasswordCallback(){};
	virtual void OnFindPassword(HttpFindPasswordTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpFindPasswordTask : public HttpRequestTask {
public:
	HttpFindPasswordTask();
	virtual ~HttpFindPasswordTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestFindPasswordCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string sendMail,
                    const string checkCode
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestFindPasswordCallback* mpCallback;

};

#endif /* HttpFindPasswordTask_H_ */
