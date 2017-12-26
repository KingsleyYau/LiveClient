/*
 * HttpOwnCheckMailRegistrationTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.8.检测邮箱注册状态（仅独立）
 */

#ifndef HttpOwnCheckMailRegistrationTask_H_
#define HttpOwnCheckMailRegistrationTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpOwnCheckMailRegistrationTask;

class IRequestOwnCheckMailRegistrationCallback {
public:
    virtual ~IRequestOwnCheckMailRegistrationCallback(){};
    virtual void OnOwnCheckMailRegistration(HttpOwnCheckMailRegistrationTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpOwnCheckMailRegistrationTask : public HttpRequestTask {
public:
    HttpOwnCheckMailRegistrationTask();
    virtual ~HttpOwnCheckMailRegistrationTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestOwnCheckMailRegistrationCallback* pCallback);
    
    /**
     * 检测邮箱注册状态
     * email          电子邮箱
     */
    void SetParam(
                  string email
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestOwnCheckMailRegistrationCallback* mpCallback;
    
    string mEmail;              // 电子邮箱

};

#endif /* HttpOwnCheckMailRegistrationTask_H_ */
