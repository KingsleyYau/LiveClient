/*
 * HttpSetManBaseInfoTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.15.设置个人信息（仅独立）
 */

#ifndef HttpSetManBaseInfoTask_H_
#define HttpSetManBaseInfoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSetManBaseInfoTask;

class IRequestSetManBaseInfoCallback {
public:
    virtual ~IRequestSetManBaseInfoCallback(){};
    virtual void OnSetManBaseInfo(HttpSetManBaseInfoTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpSetManBaseInfoTask : public HttpRequestTask {
public:
    HttpSetManBaseInfoTask();
    virtual ~HttpSetManBaseInfoTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestSetManBaseInfoCallback* pCallback);
    
    /**
     * 设置个人信息
     * nickName          昵称
     */
    void SetParam(
                  string nickName
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestSetManBaseInfoCallback* mpCallback;
    
    string mNickName;              // 昵称
};

#endif /* HttpSetManBaseInfoTask_H_ */
