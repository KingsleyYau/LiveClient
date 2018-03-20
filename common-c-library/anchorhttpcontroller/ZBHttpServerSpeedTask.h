/*
 * ZBHttpServerSpeedTask.h
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 5.3.提交流媒体服务器测速结果
 */

#ifndef ZBHttpServerSpeedTask_H_
#define ZBHttpServerSpeedTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"

class ZBHttpServerSpeedTask;

class IRequestZBServerSpeedCallback {
public:
	virtual ~IRequestZBServerSpeedCallback(){};
	virtual void OnZBServerSpeed(ZBHttpServerSpeedTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpServerSpeedTask : public ZBHttpRequestTask {
public:
	ZBHttpServerSpeedTask();
	virtual ~ZBHttpServerSpeedTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBServerSpeedCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& sid,
                    int res
                  );
    
    // 流媒体服务器ID
    const string& GetSid();
    // http请求完成时间（毫秒）
    int GetRes();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBServerSpeedCallback* mpCallback;
    // 流媒体服务器ID
    string mSid;
    // http请求完成时间（毫秒）
    int mRes;
};

#endif /* ZBHttpServerSpeedTask_H_ */
