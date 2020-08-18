/*
 * HttpSendPremiumVideoKeyRequestTask.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.4.发送解码锁请求
 */

#ifndef HttpSendPremiumVideoKeyRequestTask_H_
#define HttpSendPremiumVideoKeyRequestTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSendPremiumVideoKeyRequestTask;

class IRequestSendPremiumVideoKeyRequestCallback {
public:
	virtual ~IRequestSendPremiumVideoKeyRequestCallback(){};
	virtual void OnSendPremiumVideoKeyRequest(HttpSendPremiumVideoKeyRequestTask* task, bool success, int errnum, const string& errmsg, const string& videoId, const string& requestId) = 0;
};
      
class HttpSendPremiumVideoKeyRequestTask : public HttpRequestTask {
public:
	HttpSendPremiumVideoKeyRequestTask();
	virtual ~HttpSendPremiumVideoKeyRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendPremiumVideoKeyRequestCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& videoId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendPremiumVideoKeyRequestCallback* mpCallback;
    
    string mVideoId;


};

#endif /* HttpSendPremiumVideoKeyRequestTask_H_ */
