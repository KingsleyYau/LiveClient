/*
 * HttpSubmitFeedBackTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.13.提交Feedback（仅独立）
 */

#ifndef HttpSubmitFeedBackTask_H_
#define HttpSubmitFeedBackTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSubmitFeedBackTask;

class IRequestSubmitFeedBackCallback {
public:
    virtual ~IRequestSubmitFeedBackCallback(){};
    virtual void OnSubmitFeedBack(HttpSubmitFeedBackTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpSubmitFeedBackTask : public HttpRequestTask {
public:
    HttpSubmitFeedBackTask();
    virtual ~HttpSubmitFeedBackTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestSubmitFeedBackCallback* pCallback);
    
    /**
     * 用于观众端提交Feedback
     * mail          用户邮箱
     * msg           feedback内容
     */
    void SetParam(
                  string mail,
                  string msg
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestSubmitFeedBackCallback* mpCallback;
    
    string mMail;              // 用户邮箱
    string mMsg;                 // feedback内容
};

#endif /* HttpSubmitFeedBackTask_H_ */
