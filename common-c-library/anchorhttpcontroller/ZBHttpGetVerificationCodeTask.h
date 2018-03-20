/*
 * ZBHttpGetVerificationCodeTask.h
 *
 *  Created on: 2018-02-27
 *      Author: Alex
 *        desc: 2.3.获取验证码
 */

#ifndef ZBHttpGetVerificationCodeTask_H_
#define ZBHttpGetVerificationCodeTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpGetVerificationCodeTask;

class IRequestZBGetVerificationCodeCallback {
public:
    virtual ~IRequestZBGetVerificationCodeCallback(){};
    virtual void OnZBGetVerificationCode(ZBHttpGetVerificationCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) = 0;
};

class ZBHttpGetVerificationCodeTask : public ZBHttpRequestTask {
public:
    ZBHttpGetVerificationCodeTask();
    virtual ~ZBHttpGetVerificationCodeTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetVerificationCodeCallback* pCallback);
    
    /**
     * 获取验证码
     */
    void SetParam(
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestZBGetVerificationCodeCallback* mpCallback;
    
};

#endif /* HttpGetVerificationCodeTask_H_ */
