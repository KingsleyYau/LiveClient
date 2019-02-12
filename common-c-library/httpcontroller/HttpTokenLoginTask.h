/*
 * HttpTokenLoginTask.h
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.21.token登录
 */

#ifndef HttpTokenLoginTask_H_
#define HttpTokenLoginTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpTokenLoginTask;

class IRequestTokenLoginCallback {
public:
	virtual ~IRequestTokenLoginCallback(){};
	virtual void OnTokenLogin(HttpTokenLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) = 0;
};
      
class HttpTokenLoginTask : public HttpRequestTask {
public:
	HttpTokenLoginTask();
	virtual ~HttpTokenLoginTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestTokenLoginCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& memberId,
                    const string& sid
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestTokenLoginCallback* mpCallback;

};

#endif /* HttpTokenLoginTask_H_ */
