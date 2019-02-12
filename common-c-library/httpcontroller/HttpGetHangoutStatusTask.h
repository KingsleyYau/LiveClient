/*
 * HttpGetHangoutStatusTask.h
 *
 *  Created on: 2019-1-23
 *      Author: Alex
 *        desc: 8.11.获取当前会员Hangout直播状态
 */

#ifndef HttpGetHangoutStatusTask_H_
#define HttpGetHangoutStatusTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutStatusItem.h"

class HttpGetHangoutStatusTask;

class IRequestGetHangoutStatusCallback {
public:
	virtual ~IRequestGetHangoutStatusCallback(){};
	virtual void OnGetHangoutStatus(HttpGetHangoutStatusTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutStatusList& list) = 0;
};
      
class HttpGetHangoutStatusTask : public HttpRequestTask {
public:
	HttpGetHangoutStatusTask();
	virtual ~HttpGetHangoutStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetHangoutStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetHangoutStatusCallback* mpCallback;

};

#endif /* HttpGetHangoutStatusTask_H_ */
