/*
 * HttpPushPullLogsTask.h
 *
 *  Created on: 2020-05-14
 *      Author: Alex
 *        desc: 6.26.提交上报当前拉流的时间
 */

#ifndef HttpPushPullLogsTask_H_
#define HttpPushPullLogsTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpPushPullLogsTask;

class IRequestPushPullLogsCallback {
public:
	virtual ~IRequestPushPullLogsCallback(){};
	virtual void OnPushPullLogs(HttpPushPullLogsTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpPushPullLogsTask : public HttpRequestTask {
public:
	HttpPushPullLogsTask();
	virtual ~HttpPushPullLogsTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestPushPullLogsCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& liveRoomId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestPushPullLogsCallback* mpCallback;
    // 直播间ID
    string mLiveRoomId;
};

#endif /* HttpPushPullLogsTask_H_ */
