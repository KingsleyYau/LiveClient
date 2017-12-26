/*
 * HttpGetVerificationCodeTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 2.10.获取验证码（仅独立）
 */

#ifndef HttpGetVerificationCodeTask_H_
#define HttpGetVerificationCodeTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetVerificationCodeTask;

class IRequestGetVerificationCodeCallback {
public:
    virtual ~IRequestGetVerificationCodeCallback(){};
    virtual void OnGetVerificationCode(HttpGetVerificationCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) = 0;
};

class HttpGetVerificationCodeTask : public HttpRequestTask {
public:
    HttpGetVerificationCodeTask();
    virtual ~HttpGetVerificationCodeTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestGetVerificationCodeCallback* pCallback);
    
    /**
     * 获取验证码
     * verifyType       验证码种类，（“login”：登录；“findpw”：找回密码）
     * useCode          是否需要验证码，（1：必须；0：不限，服务端自动检测ip国家）
     */
    void SetParam(
                  VerifyCodeType verifyType,
                  bool   useCode
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestGetVerificationCodeCallback* mpCallback;
    
    VerifyCodeType mVerifyType;      // 验证码种类，（“login”：登录；“findpw”：找回密码）
    bool   mUseCode;                 // 是否需要验证码，（1：必须；0：不限，服务端自动检测ip国家）
};

#endif /* HttpGetVerificationCodeTask_H_ */
