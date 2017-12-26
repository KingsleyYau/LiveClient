/*
 * HttpOwnFindPasswordTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.7.找回密码（仅独立）
 */

#ifndef HttpOwnFindPasswordTask_H_
#define HttpOwnFindPasswordTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpOwnFindPasswordTask;

class IRequestOwnFindPasswordCallback {
public:
    virtual ~IRequestOwnFindPasswordCallback(){};
    virtual void OnOwnFindPassword(HttpOwnFindPasswordTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpOwnFindPasswordTask : public HttpRequestTask {
public:
    HttpOwnFindPasswordTask();
    virtual ~HttpOwnFindPasswordTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestOwnFindPasswordCallback* pCallback);
    
    /**
     * 找回密码
     * sendMail          用户注册的邮箱
     * checkCode         验证码
     */
    void SetParam(
                  string sendMail,
                  string checkCode
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestOwnFindPasswordCallback* mpCallback;
    
    string mSendMail;              // 用户的email或id
    string mCheckCode;             // 验证码

};

#endif /* HttpOwnFindPasswordTask_H_ */
