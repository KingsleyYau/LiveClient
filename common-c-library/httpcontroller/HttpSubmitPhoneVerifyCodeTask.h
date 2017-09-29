/*
 * HttpSubmitPhoneVerifyCodeTask.h
 *
 *  Created on: 2017-9-25
 *      Author: Alex
 *        desc: 6.7.提交手机验证码
 */

#ifndef HttpSubmitPhoneVerifyCodeTask_H_
#define HttpSubmitPhoneVerifyCodeTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSubmitPhoneVerifyCodeTask;

class IRequestSubmitPhoneVerifyCodeCallback {
public:
	virtual ~IRequestSubmitPhoneVerifyCodeCallback(){};
	virtual void OnSubmitPhoneVerifyCode(HttpSubmitPhoneVerifyCodeTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSubmitPhoneVerifyCodeTask : public HttpRequestTask {
public:
	HttpSubmitPhoneVerifyCodeTask();
	virtual ~HttpSubmitPhoneVerifyCodeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSubmitPhoneVerifyCodeCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& country,
                    const string& areaCode,
                    const string& phoneNo,
                    const string& verifyCode
                  );
    
    // 国家
    const string& GetCountry();
    // 手机区号
    const string& GetAreaCode();
    // 手机号码
    const string& GetPhoneNo();
    // 验证码
    const string& GetVerifyCode();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSubmitPhoneVerifyCodeCallback* mpCallback;
    // 国家
    string mCountry;
    // 手机区号
    string mAreaCode;
    // 手机号码
    string mPhoneNo;
    // 验证码
    string mVerifyCode;
};

#endif /* HttpSubmitPhoneVerifyCodeTask_H_ */
