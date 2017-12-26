/*
 * HttpOwnFackBookLoginTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.4.Facebook注册及登录（仅独立）
 */

#ifndef HttpOwnFackBookLoginTask_H_
#define HttpOwnFackBookLoginTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpOwnFackBookLoginTask;

class IRequestOwnFackBookLoginCallback {
public:
    virtual ~IRequestOwnFackBookLoginCallback(){};
    virtual void OnOwnFackBookLogin(HttpOwnFackBookLoginTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) = 0;
};

class HttpOwnFackBookLoginTask : public HttpRequestTask {
public:
    HttpOwnFackBookLoginTask();
    virtual ~HttpOwnFackBookLoginTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestOwnFackBookLoginCallback* pCallback);
    
    /**
     * 登录
     * model;              // 设备型号
     * deviceId;           // 设备唯一标识
     * manufacturer;       // 制造厂商
     * fToken;             // Facebook登录返回的accessToken
     * email;              // 用户注册的邮箱（可无）
     * passWord;           // 登录密码（可无）
     * birthDay;           // 出生日期（可无，但未绑定时必须提交，格式为：2015-02-20）
     * inviteCode;         // 推荐码（可无）
     * versionCode;        // 客户端内部版本号
     * utmReferrer;        // APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     */
    void SetParam(
                  string model,
                  string deviceid,
                  string manufacturer,
                  string fToken                           ,
                  string email,
                  string passWord,
                  string birthDay,
                  string inviteCode,
                  string versionCode,
                  string utmReferrer
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestOwnFackBookLoginCallback* mpCallback;
    string mDeviceId;           // 设备唯一标识
    string mModel;              // 设备型号
    string mManufacturer;       // 制造厂商
    string mFToken;             // Facebook登录返回的accessToken
    string mEmail;              // 用户注册的邮箱（可无）
    string mPassWord;           // 登录密码（可无）
    string mBirthDay;           // 出生日期（可无，但未绑定时必须提交，格式为：2015-02-20）
    string mInviteCode;         // 推荐码（可无）
    string mVersionCode;        // 客户端内部版本号
    string mUtmReferrer;        // APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
};

#endif /* HttpOwnFackBookLoginTask_H_ */
