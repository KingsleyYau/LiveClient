/*
 * HttpPasswordLoginTask.h
 *
 *  Created on: 2018-9-25
 *      Author: Alex
 *        desc: 2.20.帐号密码登录
 */

#ifndef HttpPasswordLoginTask_H_
#define HttpPasswordLoginTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpPasswordLoginTask;

class IRequestPasswordLoginCallback {
public:
	virtual ~IRequestPasswordLoginCallback(){};
	virtual void OnPasswordLogin(HttpPasswordLoginTask* task, bool success, int errnum, const string& errmsg, const string& memberId, const string& sid) = 0;
};
      
class HttpPasswordLoginTask : public HttpRequestTask {
public:
	HttpPasswordLoginTask();
	virtual ~HttpPasswordLoginTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestPasswordLoginCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& email,
                    const string& password,
                    const string& authcode,
                    HTTP_OTHER_SITE_TYPE siteId,
                    const string& afDeviceId,
                    const string& gaid,
                    const string& deviceId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestPasswordLoginCallback* mpCallback;

};

#endif /* HttpPasswordLoginTask_H_ */
