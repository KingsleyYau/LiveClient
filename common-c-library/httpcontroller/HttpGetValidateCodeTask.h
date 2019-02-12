/*
 * HttpGetValidateCodeTask.h
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.22.获取验证码
 */

#ifndef HttpGetValidateCodeTask_H_
#define HttpGetValidateCodeTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetValidateCodeTask;

class IRequestGetValidateCodeCallback {
public:
	virtual ~IRequestGetValidateCodeCallback(){};
	virtual void OnGetValidateCode(HttpGetValidateCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) = 0;
};
      
class HttpGetValidateCodeTask : public HttpRequestTask {
public:
	HttpGetValidateCodeTask();
	virtual ~HttpGetValidateCodeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetValidateCodeCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSValidateCodeType validateCodeType
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetValidateCodeCallback* mpCallback;

};

#endif /* HttpGetValidateCodeTask_H_ */
