/*
 * HttpSetPushConfigTask.h
 *
 *  Created on: 2018-9-28
 *      Author: Alex
 *        desc: 11.2.修改推送设置
 */

#ifndef HttpSetPushConfigTask_H_
#define HttpSetPushConfigTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSetPushConfigTask;

class IRequestSetPushConfigCallback {
public:
	virtual ~IRequestSetPushConfigCallback(){};
	virtual void OnSetPushConfig(HttpSetPushConfigTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSetPushConfigTask : public HttpRequestTask {
public:
	HttpSetPushConfigTask();
	virtual ~HttpSetPushConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetPushConfigCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  bool isPriMsgAppPush,
                  bool isMailAppPush
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetPushConfigCallback* mpCallback;

};

#endif /* HttpSetPushConfigTask_H_ */
