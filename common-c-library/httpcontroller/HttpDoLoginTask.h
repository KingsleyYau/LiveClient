/*
 * HttpDoLoginTask.h
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 2.18.token登录认证
 */

#ifndef HttpDoLoginTask_H_
#define HttpDoLoginTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLoginItem.h"

class HttpDoLoginTask;

class IRequestDoLoginCallback {
public:
	virtual ~IRequestDoLoginCallback(){};
	virtual void OnDoLogin(HttpDoLoginTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpDoLoginTask : public HttpRequestTask {
public:
	HttpDoLoginTask();
	virtual ~HttpDoLoginTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDoLoginCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& token,
                  const string& memberId,
                  const string& deviceId,
                  const string& versionCode,
                  const string& model,
                  const string& manufacturer
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestDoLoginCallback* mpCallback;

};

#endif /* HttpDoLoginTask_H_ */
