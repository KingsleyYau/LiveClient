/*
 * HttpGetManBaseInfoTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 6.14.获取个人信息（仅独立）
 */

#ifndef HttpGetManBaseInfoTask_H_
#define HttpGetManBaseInfoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "item/HttpManBaseInfoItem.h"

class HttpGetManBaseInfoTask;

class IRequestGetManBaseInfoCallback {
public:
    virtual ~IRequestGetManBaseInfoCallback(){};
    virtual void OnGetManBaseInfo(HttpGetManBaseInfoTask* task, bool success, int errnum, const string& errmsg, const HttpManBaseInfoItem& infoItem) = 0;
};

class HttpGetManBaseInfoTask : public HttpRequestTask {
public:
    HttpGetManBaseInfoTask();
    virtual ~HttpGetManBaseInfoTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestGetManBaseInfoCallback* pCallback);
    
    void SetParam(
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestGetManBaseInfoCallback* mpCallback;

};

#endif /* HttpGetManBaseInfoTask_H_ */
