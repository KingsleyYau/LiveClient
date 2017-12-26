/*
 * HttpPremiumMembershipTask.h
 *
 *  Created on: 2017-12-22
 *      Author: Alex
 *        desc: 7.1.获取买点信息（仅独立）（仅iOS）
 */

#ifndef HttpPremiumMembershipTask_H_
#define HttpPremiumMembershipTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "item/HttpOrderProductItem.h"

class HttpPremiumMembershipTask;

class IRequestPremiumMembershipCallback {
public:
    virtual ~IRequestPremiumMembershipCallback(){};
    virtual void OnPremiumMembership(HttpPremiumMembershipTask* task, bool success, int errnum, const string& errmsg, const HttpOrderProductItem& productItem) = 0;
};

class HttpPremiumMembershipTask : public HttpRequestTask {
public:
    HttpPremiumMembershipTask();
    virtual ~HttpPremiumMembershipTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestPremiumMembershipCallback* pCallback);
    
    /**
     * 获取买点信息
     * siteId          站点ID
     */
    void SetParam(
                  string siteId
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestPremiumMembershipCallback* mpCallback;
    
    string mSiteId;              // 站点ID
};

#endif /* HttpPremiumMembershipTask_H_ */
