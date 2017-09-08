/*
 * HttpLogoutTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 2.2.注销
 */

#ifndef HttpLogoutTask_H_
#define HttpLogoutTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpLogoutTask;

class IRequestLogoutCallback {
public:
	virtual ~IRequestLogoutCallback(){};
	virtual void OnLogout(HttpLogoutTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpLogoutTask : public HttpRequestTask {
public:
	HttpLogoutTask();
	virtual ~HttpLogoutTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestLogoutCallback* pCallback);

    /**
     * 注销
     */
	void SetParam(
			);


protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestLogoutCallback* mpCallback;
    
};

#endif /* HttpLogoutTask_H_ */
