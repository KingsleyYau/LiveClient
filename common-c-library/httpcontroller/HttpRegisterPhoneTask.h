/*
 * HttpRegisterPhoneTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.3.手机注册
 */

#ifndef HttpRegisterPhoneTask_H_
#define HttpRegisterPhoneTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpRegisterPhoneTask;

class IRequestRegisterPhoneCallback {
public:
	virtual ~IRequestRegisterPhoneCallback(){};
	virtual void OnRegisterPhone(HttpRegisterPhoneTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpRegisterPhoneTask : public HttpRequestTask {
public:
	HttpRegisterPhoneTask();
	virtual ~HttpRegisterPhoneTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRegisterPhoneCallback* pCallback);

    /**
     * 获取手机注册短信验证码
     * @param phoneNo			   手机号码
     * @param areaNo			   手机区号
     * @param checkCode			   验证码
     * @param password			   密码
     * @param deviceId			   设备唯一标识
     * @param model			       设备型号（格式：设备号－系统版本号）
     * @param manufacturer		   制造厂商
     */
    void SetParam(
                  string phoneNo,
                  string areaNo,
                  string checkCode,
                  string password,
                  string deviceId,
                  string model,
                  string manufacturer
                  );
    
    /**
     * 获取手机号码
     */
    const string& GetPhoneNo();
    
    /**
     * 获取手机区号
     */
    const string& GetAreaNo();
    
    /**
     * 获取验证码
     */
    const string& GetCheckCode();
    
    /**
     * 获取密码
     */
    const string& GetPassword();
    
    /**
     * 获取设备唯一标识
     */
    const string& GetDeviceId();
    
    /**
     * 获取设备型号（格式：设备号－系统版本号）
     */
    const string& GetModel();
    
    /**
     * 获取制造厂商
     */
    const string& GetManufacturer();

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRegisterPhoneCallback* mpCallback;
    
    // 手机号码
    string mPhoneNo;
    // 手机区号
    string mAreaNo;
    // 验证码
    string mCheckCode;
    // 密码
    string mPassword;
    // 设备唯一标识
    string mDeviceId;
    // 设备型号（格式：设备号－系统版本号）
    string mModel;
    // 制造厂商
    string mManufacturer;

};

#endif /* HttpRegisterPhoneTask_H_ */
