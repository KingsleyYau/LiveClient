/*
 * HttpGetTokenTask.h
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.19.获取认证token
 */

#ifndef HttpGetTokenTask_H_
#define HttpGetTokenTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetTokenTask;

class IRequestGetTokenCallback {
public:
	virtual ~IRequestGetTokenCallback(){};
	virtual void OnGetToken(HttpGetTokenTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) = 0;
};
      
class HttpGetTokenTask : public HttpRequestTask {
public:
	HttpGetTokenTask();
	virtual ~HttpGetTokenTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetTokenCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& url,
                    HTTP_OTHER_SITE_TYPE siteId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetTokenCallback* mpCallback;

};

#endif /* HttpGetTokenTask_H_ */
