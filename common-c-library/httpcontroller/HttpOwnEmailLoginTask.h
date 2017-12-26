/*
 * HttpOwnEmailLoginTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.6.邮箱登录（仅独立）
 */

#ifndef HttpOwnEmailLoginTask_H_
#define HttpOwnEmailLoginTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpOwnEmailLoginTask;

class IRequestOwnEmailLoginCallback {
public:
    virtual ~IRequestOwnEmailLoginCallback(){};
    virtual void OnOwnEmailLogin(HttpOwnEmailLoginTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) = 0;
};

class HttpOwnEmailLoginTask : public HttpRequestTask {
public:
    HttpOwnEmailLoginTask();
    virtual ~HttpOwnEmailLoginTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestOwnEmailLoginCallback* pCallback);
    
    /**
     * 邮箱登录
     * email              用户的email或id
     * passWord           登录密码
     * versionCode        客户端内部版本号
     * model              设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
     * deviceId           设备唯一标识
     * manufacturer       制造厂商
     * checkCode          验证码
     */
    void SetParam(
                  string email,
                  string passWord,
                  string versionCode,
                  string model,
                  string deviceid,
                  string manufacturer,
                  string checkCode
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestOwnEmailLoginCallback* mpCallback;
    
    string mEmail;              // 用户的email或id
    string mPassWord;           // 登录密码
    string mVersionCode;        // 客户端内部版本号
    string mModel;              // 设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
    string mDeviceId;           // 设备唯一标识
    string mManufacturer;       // 制造厂商
    string mCheckCode;          // 验证码

};

#endif /* HttpOwnEmailLoginTask_H_ */
