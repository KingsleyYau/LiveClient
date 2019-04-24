/*
 * HttpSendSayHiTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.4.发送sayHi
 */

#ifndef HttpSendSayHiTask_H_
#define HttpSendSayHiTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSendSayHiTask;

class IRequestSendSayHiCallback {
public:
	virtual ~IRequestSendSayHiCallback(){};
	virtual void OnSendSayHi(HttpSendSayHiTask* task, bool success, int errnum, const string& errmsg, const string& sayHiId, const string& sayHiOrLoiId) = 0;
};
      
class HttpSendSayHiTask : public HttpRequestTask {
public:
	HttpSendSayHiTask();
	virtual ~HttpSendSayHiTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendSayHiCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& anchorId,
                    int themeId,
                    int textId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendSayHiCallback* mpCallback;

};

#endif /* HttpSendSayHiTask_H_ */
