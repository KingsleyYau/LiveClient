/*
 * HttpGetIOSPayTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 7.2.获取订单信息（仅独立）（仅iOS）
 */

#ifndef HttpGetIOSPayTask_H_
#define HttpGetIOSPayTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetIOSPayTask;

class IRequestGetIOSPayCallback {
public:
    virtual ~IRequestGetIOSPayCallback(){};
    virtual void OnGetIOSPay(HttpGetIOSPayTask* task, bool success, const string& code, const string& orderNo, const string& productId) = 0;
};

class HttpGetIOSPayTask : public HttpRequestTask {
public:
    HttpGetIOSPayTask();
    virtual ~HttpGetIOSPayTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestGetIOSPayCallback* pCallback);
    
    /**
     * 获取订单信息
     * manid            男士ID
     * sid              跨服务器唯一标识
     * number           信用点套餐ID
     * siteid           站点ID
     */
    void SetParam(
                  string manid,
                  string sid,
                  string number,
                  string siteid
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestGetIOSPayCallback* mpCallback;
    
    string mManid;              // 男士ID
    string mSid;                // 跨服务器唯一标识
    string mNumber;             // 信用点套餐ID
    string mSiteid;             // 站点ID
};

#endif /* HttpGetIOSPayTask_H_ */
