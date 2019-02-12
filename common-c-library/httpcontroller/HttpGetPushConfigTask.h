/*
 * HttpGetPushConfigTask.h
 *
 *  Created on: 2018-9-28
 *      Author: Alex
 *        desc: 11.1.获取推送设置
 */

#ifndef HttpGetPushConfigTask_H_
#define HttpGetPushConfigTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetPushConfigTask;

class IRequestGetPushConfigCallback {
public:
	virtual ~IRequestGetPushConfigCallback(){};
	virtual void OnGetPushConfig(HttpGetPushConfigTask* task, bool success, int errnum, const string& errmsg, bool isPriMsgAppPush, bool isMailAppPush) = 0;
};
      
class HttpGetPushConfigTask : public HttpRequestTask {
public:
	HttpGetPushConfigTask();
	virtual ~HttpGetPushConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPushConfigCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPushConfigCallback* mpCallback;

};

#endif /* HttpGetPushConfigTask_H_ */
