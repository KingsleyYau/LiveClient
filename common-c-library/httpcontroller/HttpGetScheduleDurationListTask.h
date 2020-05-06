/*
 * HttpGetScheduleDurationListTask.h
 *
 *  Created on: 2020-3-16
 *      Author: Alex
 *        desc: 17.1.获取时长价格配置列表
 */

#ifndef HttpGetScheduleDurationListTask_H_
#define HttpGetScheduleDurationListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpScheduleDurationItem.h"


class HttpGetScheduleDurationListTask;

class IRequestGetScheduleDurationListCallback {
public:
	virtual ~IRequestGetScheduleDurationListCallback(){};
	virtual void OnGetScheduleDurationList(HttpGetScheduleDurationListTask* task, bool success, int errnum, const string& errmsg, const ScheduleDurationList& list) = 0;
};
      
class HttpGetScheduleDurationListTask : public HttpRequestTask {
public:
	HttpGetScheduleDurationListTask();
	virtual ~HttpGetScheduleDurationListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetScheduleDurationListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetScheduleDurationListCallback* mpCallback;

};

#endif /* HttpGetScheduleDurationListTask_H */
