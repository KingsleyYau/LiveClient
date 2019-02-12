/*
 * HttpGetEmfDetailTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.4.获取信件详情
 */

#ifndef HttpGetEmfDetailTask_H_
#define HttpGetEmfDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpDetailEmfItem.h"

class HttpGetEmfDetailTask;

class IRequestGetEmfDetailCallback {
public:
	virtual ~IRequestGetEmfDetailCallback(){};
	virtual void OnGetEmfDetail(HttpGetEmfDetailTask* task, bool success, int errnum, const string& errmsg, const HttpDetailEmfItem& detailEmfItem) = 0;
};
      
class HttpGetEmfDetailTask : public HttpRequestTask {
public:
	HttpGetEmfDetailTask();
	virtual ~HttpGetEmfDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetEmfDetailCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    string loiId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetEmfDetailCallback* mpCallback;

};

#endif /*HttpGetEmfDetailTask_H_ */
