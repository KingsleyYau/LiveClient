/*
 * HttpServerSpeedTask.h
 *
 *  Created on: 2017-10-13
 *      Author: Alex
 *        desc: 6.8.提交流媒体服务器测速结果
 */

#ifndef HttpServerSpeedTask_H_
#define HttpServerSpeedTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpServerSpeedTask;

class IRequestServerSpeedCallback {
public:
	virtual ~IRequestServerSpeedCallback(){};
	virtual void OnServerSpeed(HttpServerSpeedTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpServerSpeedTask : public HttpRequestTask {
public:
	HttpServerSpeedTask();
	virtual ~HttpServerSpeedTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestServerSpeedCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& sid,
                    int res,
                    const string& liveRoomId
                  );
    
    // 流媒体服务器ID
    const string& GetSid();
    // http请求完成时间（毫秒）
    int GetRes();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestServerSpeedCallback* mpCallback;
    // 流媒体服务器ID
    string mSid;
    // http请求完成时间（毫秒）
    int mRes;
    // 直播间ID
    string mLiveRoomId;
};

#endif /* HttpServerSpeedTask_H_ */
