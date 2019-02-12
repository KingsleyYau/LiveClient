/*
 * HttpGetValidsiteIdTask.h
 *
 *  Created on: 2018-9-19
 *      Author: Alex
 *        desc: 2.13.可登录的站点列表
 */

#ifndef HttpGetValidsiteIdTask_H_
#define HttpGetValidsiteIdTask_H_

#include "HttpRequestTask.h"
#include "item/HttpValidSiteIdItem.h"

class HttpGetValidsiteIdTask;

class IRequestGetValidsiteIdCallback {
public:
	virtual ~IRequestGetValidsiteIdCallback(){};
	virtual void OnGetValidsiteId(HttpGetValidsiteIdTask* task, bool success, const string& errnum, const string& errmsg, const HttpValidSiteIdList& SiteIdList) = 0;
};
      
class HttpGetValidsiteIdTask : public HttpRequestTask {
public:
	HttpGetValidsiteIdTask();
	virtual ~HttpGetValidsiteIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetValidsiteIdCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& email,
                  const string& password
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetValidsiteIdCallback* mpCallback;
    
    string mEmail;
    string mPassword;

};

#endif /* HttpGetValidsiteIdTask_H_ */
