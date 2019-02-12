/*
 * HttpIOSPremiumMemberShipTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.6.获取产品列表（仅iOS）
 */

#ifndef HttpIOSPremiumMemberShipTask_H_
#define HttpIOSPremiumMemberShipTask_H_

#include "HttpRequestTask.h"
#include "item/HttpOrderProductItem.h"

class HttpIOSPremiumMemberShipTask;

class IRequestIOSPremiumMemberShipCallback {
public:
	virtual ~IRequestIOSPremiumMemberShipCallback(){};
	virtual void OnIOSPremiumMemberShip(HttpIOSPremiumMemberShipTask* task, bool success, const string& errnum, const string& errmsg, const HttpOrderProductItem& productItem) = 0;
};
      
class HttpIOSPremiumMemberShipTask : public HttpRequestTask {
public:
	HttpIOSPremiumMemberShipTask();
	virtual ~HttpIOSPremiumMemberShipTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestIOSPremiumMemberShipCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestIOSPremiumMemberShipCallback* mpCallback;

};

#endif /* HttpIOSPremiumMemberShipTask_H_ */
