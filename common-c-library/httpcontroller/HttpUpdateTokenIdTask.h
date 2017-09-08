/*
 * HttpUpdateTokenIdTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 2.3.上传tokenid接口
 */

#ifndef HttpUpdateTokenIdTask_H_
#define HttpUpdateTokenIdTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpUpdateTokenIdTask;

class IRequestUpdateTokenIdCallback {
public:
	virtual ~IRequestUpdateTokenIdCallback(){};
	virtual void OnUpdateTokenId(HttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpUpdateTokenIdTask : public HttpRequestTask {
public:
	HttpUpdateTokenIdTask();
	virtual ~HttpUpdateTokenIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUpdateTokenIdCallback* pCallback);

    /**
     * 关闭直播间
     * @param tokenId			       用于Push Notification的ID
     */
    void SetParam(
                  string tokenId
                  );
    
    /**
     * 获取用于Push Notification的ID
     */
    const string& GetmTokenId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUpdateTokenIdCallback* mpCallback;
    
    // 用于Push Notification的ID
    string mTokenId;

};

#endif /* HttpUpdateTokenIdTask_H_ */
