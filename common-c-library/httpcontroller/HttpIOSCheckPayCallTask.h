/*
 * HttpIOSCheckPayCallTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 7.5.验证订单信息（仅iOS）
 */

#ifndef HttpIOSCheckPayCallTask_H_
#define HttpIOSCheckPayCallTask_H_

#include "HttpRequestTask.h"
#include "item/HttpOrderProductItem.h"

class HttpIOSCheckPayCallTask;

class IRequestIOSCheckPayCallCallback {
public:
	virtual ~IRequestIOSCheckPayCallCallback(){};
	virtual void OnIOSCheckPayCall(HttpIOSCheckPayCallTask* task, bool success, const string& code) = 0;
};
      
class HttpIOSCheckPayCallTask : public HttpRequestTask {
public:
	HttpIOSCheckPayCallTask();
	virtual ~HttpIOSCheckPayCallTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestIOSCheckPayCallCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string manid,
                  string sid,
                  string receipt,
                  string orderNo,
                  AppStorePayCodeType code
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestIOSCheckPayCallCallback* mpCallback;

};

#endif /* HttpIOSCheckPayCallTask_H_ */
