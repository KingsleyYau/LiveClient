/*
 * HttpGetVoucherAvailableInfoTask.h
 *
 *  Created on: 2018-1-24
 *      Author: Alex
 *        desc: 5.6.获取试用券可用信息
 */

#ifndef HttpGetVoucherAvailableInfoTask_H_
#define HttpGetVoucherAvailableInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVoucherInfoItem.h"

class HttpGetVoucherAvailableInfoTask;

class IRequestGetVoucherAvailableInfoCallback {
public:
	virtual ~IRequestGetVoucherAvailableInfoCallback(){};
	virtual void OnGetVoucherAvailableInfo(HttpGetVoucherAvailableInfoTask* task, bool success, int errnum, const string& errmsg, const HttpVoucherInfoItem& item) = 0;
};
      
class HttpGetVoucherAvailableInfoTask : public HttpRequestTask {
public:
	HttpGetVoucherAvailableInfoTask();
	virtual ~HttpGetVoucherAvailableInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetVoucherAvailableInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetVoucherAvailableInfoCallback* mpCallback;

};

#endif /* HttpGetVoucherAvailableInfoTask_H_ */
