/*
 * HttpAndroidPremiumMemberShipTask.h
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.2.获取商品列表（仅Android）
 */

#ifndef HttpAndroidPremiumMemberShipTask_H_
#define HttpAndroidPremiumMemberShipTask_H_

#include "HttpRequestTask.h"
#include "item/HttpAndroidProductItem.h"

class HttpAndroidPremiumMemberShipTask;

class IRequestAndroidPremiumMemberShipCallback {
public:
	virtual ~IRequestAndroidPremiumMemberShipCallback(){};
	virtual void OnAndroidPremiumMemberShip(HttpAndroidPremiumMemberShipTask* task, bool success, const string& errnum, const string& errmsg, const HttpAndroidProductItem& productItem) = 0;
};
      
class HttpAndroidPremiumMemberShipTask : public HttpRequestTask {
public:
	HttpAndroidPremiumMemberShipTask();
	virtual ~HttpAndroidPremiumMemberShipTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAndroidPremiumMemberShipCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAndroidPremiumMemberShipCallback* mpCallback;

};

#endif /* HttpAndroidPremiumMemberShipTask_H_ */
