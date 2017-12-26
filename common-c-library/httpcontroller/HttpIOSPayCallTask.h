/*
 * HttpIOSPayCallTask.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 7.3.验证订单信息（仅独立）（仅iOS）
 */

#ifndef HttpIOSPayCallTask_H_
#define HttpIOSPayCallTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpIOSPayCallTask;

class IRequestIOSPayCallCallback {
public:
    virtual ~IRequestIOSPayCallCallback(){};
    virtual void OnIOSPayCall(HttpIOSPayCallTask* task, bool success, const string& code) = 0;
};

class HttpIOSPayCallTask : public HttpRequestTask {
public:
    HttpIOSPayCallTask();
    virtual ~HttpIOSPayCallTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestIOSPayCallCallback* pCallback);
    
    /**
     * 获取订单信息
     * manid            男士ID
     * sid              跨服务器唯一标识
     * receipt          AppStore支付成功返回的receipt参数
     * orderNo          订单号
     * code             AppStore支付完成返回的状态code（APPSTOREPAYTYPE_PAYSUCCES：支付成功，APPSTOREPAYTYPE_PAYFAIL：支付失败，APPSTOREPAYTYPE_PAYRECOVERY：恢复交易(仅非消息及自动续费商品)，APPSTOREPAYTYPE_NOIMMEDIATELYPAY：无法立即支付）（可无，默认：APPSTOREPAYTYPE_PAYSUCCES）
     */
    void SetParam(
                  string manid,
                  string sid,
                  string receipt,
                  string orderNo,
                  AppStorePayCodeType code
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestIOSPayCallCallback* mpCallback;
    
    string mManid;              // 男士ID
    string mSid;                // 跨服务器唯一标识
    string mReceipt;             // AppStore支付成功返回的receipt参数
    string mOrderno;             // 订单号
    AppStorePayCodeType mCode;    // AppStore支付完成返回的状态code（1：支付成功，2：支付失败，3：恢复交易(仅非消息及自动续费商品)，4：无法立即支付）（可无，默认：1）
};

#endif /* HttpIOSPayCallTask_H_ */
