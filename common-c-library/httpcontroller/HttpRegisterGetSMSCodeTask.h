/*
 * HttpRegisterGetSMSCodeTask
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.2.获取手机注册短信验证码
 */

#ifndef HttpRegisterGetSMSCodeTask_H_
#define HttpRegisterGetSMSCodeTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"


class HttpRegisterGetSMSCodeTask;

class IRequestRegisterGetSMSCodeCallback {
public:
	virtual ~IRequestRegisterGetSMSCodeCallback(){};
	virtual void OnRegisterGetSMSCode(HttpRegisterGetSMSCodeTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpRegisterGetSMSCodeTask : public HttpRequestTask {
public:
	HttpRegisterGetSMSCodeTask();
	virtual ~HttpRegisterGetSMSCodeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRegisterGetSMSCodeCallback* pCallback);

    /**
     * 获取手机注册短信验证码
     * @param phoneNo			   手机号码
     * @param areaNo			   手机区号
     */
    void SetParam(
                  string phoneNo,
                  string areaNo
                  );

    /**
     * 获取手机号码
     */
    const string& GetPhoneNo();
    
    /**
     * 获取手机区号
     */
    const string& GetAreaNo();
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRegisterGetSMSCodeCallback* mpCallback;
    
    // 手机号码
    string mPhoneNo;
    // 手机区号
    string mAreaNo;
};

#endif /* HttpRegisterGetSMSCodeTask_H_ */
