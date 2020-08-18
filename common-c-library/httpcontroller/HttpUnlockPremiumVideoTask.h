/*
 * HttpUnlockPremiumVideoTask.h
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *        desc: 18.14.视频解锁
 */

#ifndef HttpUnlockPremiumVideoTask_H_
#define HttpUnlockPremiumVideoTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpUnlockPremiumVideoTask;

class IRequestUnlockPremiumVideoCallback {
public:
	virtual ~IRequestUnlockPremiumVideoCallback(){};
	virtual void OnUnlockPremiumVideo(HttpUnlockPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId, const string& videoUrlFull) = 0;
};
      
class HttpUnlockPremiumVideoTask : public HttpRequestTask {
public:
	HttpUnlockPremiumVideoTask();
	virtual ~HttpUnlockPremiumVideoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUnlockPremiumVideoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   LSUnlockActionType type,
                   const string& accessKey,
                  const string& videoId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUnlockPremiumVideoCallback* mpCallback;
    
    string mVideoId;


};

#endif /* HttpUnlockPremiumVideoTask_H_ */
