/*
 * HttpGetActivityTimeTask.h
 *
 *  Created on: 2020-5-07
 *      Author: Alex
 *        desc: 17.11.获取服务器当前GMT时间戳
 */

#ifndef HttpGetActivityTimeTask_H_
#define HttpGetActivityTimeTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"


class HttpGetActivityTimeTask;

class IRequestGetActivityTimeCallback {
public:
	virtual ~IRequestGetActivityTimeCallback(){};
	virtual void OnGetActivityTime(HttpGetActivityTimeTask* task, bool success, int errnum, const string& errmsg, long long activityTime) = 0;
};
      
class HttpGetActivityTimeTask : public HttpRequestTask {
public:
	HttpGetActivityTimeTask();
	virtual ~HttpGetActivityTimeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetActivityTimeCallback* pCallback);

    /**
     *
     */
    void SetParam(

                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetActivityTimeCallback* mpCallback;

};

#endif /* HttpGetActivityTimeTask_H */
