/*
 * HttpLogoutTask.h
 *
 *  Created on: 2017-5-18
 *      Author: Alex
 *        desc: 2.5.注销
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
     * @param token			   用户身份唯一标识
     */
	void SetParam(
			string token
			);

	/**
	 * 获取用户身份唯一标识
	 */
	const string& GetToken();


protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestLogoutCallback* mpCallback;
    
	string mToken;
};

#endif /* HttpLogoutTask_H_ */
