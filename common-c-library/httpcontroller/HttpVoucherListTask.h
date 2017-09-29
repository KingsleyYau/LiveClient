/*
 * HttpVoucherListTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.2.获取使用劵列表
 */

#ifndef HttpVoucherListTask_H_
#define HttpVoucherListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVoucherItem.h"

class HttpVoucherListTask;

class IRequestVoucherListCallback {
public:
	virtual ~IRequestVoucherListCallback(){};
	virtual void OnVoucherList(HttpVoucherListTask* task, bool success, int errnum, const string& errmsg, const VoucherList& list, int totalCount) = 0;
};
      
class HttpVoucherListTask : public HttpRequestTask {
public:
	HttpVoucherListTask();
	virtual ~HttpVoucherListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestVoucherListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestVoucherListCallback* mpCallback;
    

};

#endif /* HttpVoucherListTask_H_ */
