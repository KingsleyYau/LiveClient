/*
 * HttpCanSendEmfTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.9.获取主播信件权限
 */

#ifndef HttpCanSendEmfTask_H_
#define HttpCanSendEmfTask_H_

#include "HttpRequestTask.h"
#include "item/HttpAnchorSendEmfPrivItem.h"

class HttpCanSendEmfTask;

class IRequestCanSendEmfCallback {
public:
	virtual ~IRequestCanSendEmfCallback(){};
	virtual void OnCanSendEmf(HttpCanSendEmfTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorSendEmfPrivItem& item) = 0;
};
      
class HttpCanSendEmfTask : public HttpRequestTask {
public:
	HttpCanSendEmfTask();
	virtual ~HttpCanSendEmfTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCanSendEmfCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& anchorId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestCanSendEmfCallback* mpCallback;

};

#endif /* HttpCanSendEmfTask_H_ */
