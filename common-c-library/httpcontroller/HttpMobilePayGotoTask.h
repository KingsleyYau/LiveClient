/*
 * HttpMobilePayGotoTask.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 7.7.获取h5买点页面URL（仅Android）
 */

#ifndef HttpMobilePayGotoTask_H_
#define HttpMobilePayGotoTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"


class HttpMobilePayGotoTask;

class IRequestMobilePayGotoCallback {
public:
	virtual ~IRequestMobilePayGotoCallback(){};
	virtual void OnMobilePayGoto(HttpMobilePayGotoTask* task, bool success, int errnum, const string& errmsg, const string& redirect) = 0;
};
      
class HttpMobilePayGotoTask : public HttpRequestTask {
public:
	HttpMobilePayGotoTask();
	virtual ~HttpMobilePayGotoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestMobilePayGotoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& url,
                  HTTP_OTHER_SITE_TYPE siteId,
                  LSOrderType orderType,
                  const string& clickFrom,
                  const string& number,
                  const string& orderNo
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestMobilePayGotoCallback* mpCallback;

};

#endif /* HttpMobilePayGotoListTask_H */
