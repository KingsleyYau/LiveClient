/*
 * HttpRegisterCheckPhoneTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.1.验证手机是否已注册
 */

#ifndef HttpRegisterCheckPhoneTask_H_
#define HttpRegisterCheckPhoneTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpRegisterCheckPhoneTask;

class IRequestRegisterCheckPhoneCallback {
public:
	virtual ~IRequestRegisterCheckPhoneCallback(){};
	virtual void OnRegisterCheckPhone(HttpRegisterCheckPhoneTask* task, bool success, int errnum, const string& errmsg, bool isRegistered) = 0;
};

class HttpRegisterCheckPhoneTask : public HttpRequestTask {
public:
	HttpRegisterCheckPhoneTask();
	virtual ~HttpRegisterCheckPhoneTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRegisterCheckPhoneCallback* pCallback);

    /**
     * 验证手机是否已注册
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
	IRequestRegisterCheckPhoneCallback* mpCallback;
    // 手机号码
	string mPhoneNo;
    // 手机区号
    string mAreaNo;
    
    // 是否已注册（返回）
    int mRegistered;
};

#endif /* HttpRegisterCheckPhoneTask_H_ */
