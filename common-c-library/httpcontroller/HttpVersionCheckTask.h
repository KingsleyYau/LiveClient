/*
 * HttpVersionCheckTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 6.20.检查客户端更新
 */

#ifndef HttpVersionCheckTask_H_
#define HttpVersionCheckTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpVersionCheckTask;

class IRequestVersionCheckCallback {
public:
	virtual ~IRequestVersionCheckCallback(){};
	virtual void OnVersionCheck(HttpVersionCheckTask* task, bool success, const string& errnum, const string& errmsg, const HttpVersionCheckItem& versionItem) = 0;
};
      
class HttpVersionCheckTask : public HttpRequestTask {
public:
	HttpVersionCheckTask();
	virtual ~HttpVersionCheckTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestVersionCheckCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int currVersion
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestVersionCheckCallback* mpCallback;

};

#endif /* HttpVersionCheckTask_H_ */
