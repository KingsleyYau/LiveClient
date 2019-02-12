/*
 * HttpChangePasswordTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 2.17.修改密码
 */

#ifndef HttpChangePasswordTask_H_
#define HttpChangePasswordTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpChangePasswordTask;

class IRequestChangePasswordCallback {
public:
	virtual ~IRequestChangePasswordCallback(){};
	virtual void OnChangePassword(HttpChangePasswordTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpChangePasswordTask : public HttpRequestTask {
public:
	HttpChangePasswordTask();
	virtual ~HttpChangePasswordTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestChangePasswordCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string passwordNew,
                    const string passwordOld
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestChangePasswordCallback* mpCallback;

};

#endif /* HttpChangePasswordTask_H_ */
