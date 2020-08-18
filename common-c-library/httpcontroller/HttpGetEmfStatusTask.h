/*
 * HttpGetEmfStatusTask.h
 *
 *  Created on: 2020-08-13
 *      Author: Alex
 *        desc: 13.10.获取EMF状态
 */

#ifndef HttpGetEmfStatusTask_H_
#define HttpGetEmfStatusTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpGetEmfStatusTask;

class IRequestGetEmfStatusCallback {
public:
	virtual ~IRequestGetEmfStatusCallback(){};
	virtual void OnGetEmfStatus(HttpGetEmfStatusTask* task, bool success, int errnum, const string& errmsg, bool hasRead) = 0;
};
      
class HttpGetEmfStatusTask : public HttpRequestTask {
public:
	HttpGetEmfStatusTask();
	virtual ~HttpGetEmfStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetEmfStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& emfId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetEmfStatusCallback* mpCallback;

};

#endif /* HttpGetEmfStatusTask_H_ */
