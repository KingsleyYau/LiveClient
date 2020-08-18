/*
 * HttpOrderExpiredReportTask.h
 *
 *  Created on: 2020-06-29
 *      Author: Alex
 *        desc: 16.5.Google失效订单列表上传（仅Android）
 */

#ifndef HttpOrderExpiredReportTask_H_
#define HttpOrderExpiredReportTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpOrderExpiredItem.h"

class HttpOrderExpiredReportTask;

class IRequestOrderExpiredReportCallback {
public:
	virtual ~IRequestOrderExpiredReportCallback(){};
	virtual void OnOrderExpiredReport(HttpOrderExpiredReportTask* task, bool success, const string& code, const string& errmsg) = 0;
};
      
class HttpOrderExpiredReportTask : public HttpRequestTask {
public:
	HttpOrderExpiredReportTask();
	virtual ~HttpOrderExpiredReportTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestOrderExpiredReportCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string manId,
                  string deviceId,
                  string deviceModel,
                  string system,
                  string appSdk,
                  OrderExpiredList list
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestOrderExpiredReportCallback* mpCallback;

};

#endif /* HttpOrderExpiredReportTask_H_ */
