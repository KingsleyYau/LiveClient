/*
 * HttpLoginTask.h
 *
 *  Created on: 2017-5-19
 *      Author: Alex
 *        desc: 2.4.登录 
 */

#ifndef HttpLoginTask_H_
#define HttpLoginTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLoginItem.h"

class HttpLoginTask;

class IRequestLoginCallback {
public:
    virtual ~IRequestLoginCallback(){};
    virtual void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item) = 0;
};

class HttpLoginTask : public HttpRequestTask {
public:
    HttpLoginTask();
    virtual ~HttpLoginTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestLoginCallback* pCallback);
    
    /**
     * 登录
     * @param type				登录类型（0: 手机登录 1:邮箱登录）
     * @param phoneno           手机号码（仅当type ＝ 0 时使用）
     * @param areno				手机区号（仅当type ＝ 0 时使用）
     * @param password			登录密码
     * @param deviceid		    设备唯一标识
     * @param model				设备型号（格式：设备型号－系统版本号）
     * @param manufacturer		制造厂商
     */
    void SetParam(
                  LoginType    type,
                  string phoneno,
                  string areno,
                  string password,
                  string deviceid,
                  string model,
                  string manufacturer,
                  bool   autoLogin
                  );
    
    /**
     * 获取登录类型（0: 手机登录 1:邮箱登录）
     */
    int GetType();
    
    /**
     * 获取手机号码（仅当type ＝ 0 时使用）
     */
    const string& GetPhoneNo();
    /**
     * 获取手机区号（仅当type ＝ 0 时使用）
     */
    const string& GetAreNo();
    
    /**
     * 获取登录密码
     */
    const string& GetPassword();
    
    /**
     * 获取设备唯一标识
     */
    const string& GetDeviceId();
    
    /**
     * 获取设备型号（格式：设备型号－系统版本号）
     */
    const string& GetModel();
    
    /**
     * 获取设备型号（格式：设备型号－系统版本号）
     */
    const string& GetManufacturer();
    
    /**
     * 是否自动登录
     */
    bool GetAutoLogin();
    
    /**
     * 获取制造厂商
     */
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestLoginCallback* mpCallback;
    LoginType    mType;
    string mPhoneNo;
    string mAreNo;
    string mPassword;
    string mDeviceId;
    string mModel;
    string mManufacturer;
    bool   mAutoLogin;
};

#endif /* HttpLoginTask_H_ */
