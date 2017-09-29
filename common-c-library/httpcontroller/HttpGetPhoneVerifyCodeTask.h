/*
 * HttpGetPhoneVerifyCodeTask.h
 *
 *  Created on: 2017-9-25
 *      Author: Alex
 *        desc: 6.6.获取手机验证码
 */

#ifndef HttpGetPhoneVerifyCodeTask_H_
#define HttpGetPhoneVerifyCodeTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpGetPhoneVerifyCodeTask;

class IRequestGetPhoneVerifyCodeCallback {
public:
	virtual ~IRequestGetPhoneVerifyCodeCallback(){};
	virtual void OnGetPhoneVerifyCode(HttpGetPhoneVerifyCodeTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpGetPhoneVerifyCodeTask : public HttpRequestTask {
public:
	HttpGetPhoneVerifyCodeTask();
	virtual ~HttpGetPhoneVerifyCodeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPhoneVerifyCodeCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& country,
                    const string& areaCode,
                    const string& phoneNo
                  );
    
    // 国家
    const string& GetCountry();
    // 手机区号
    const string& GetAreaCode();
    // 手机号码
    const string& GetPhoneNo();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPhoneVerifyCodeCallback* mpCallback;
    // 国家
    string mCountry;
    // 手机区号
    string mAreaCode;
    // 手机号码
    string mPhoneNo;
};

#endif /* HttpGetPhoneVerifyCodeTask_H_ */
