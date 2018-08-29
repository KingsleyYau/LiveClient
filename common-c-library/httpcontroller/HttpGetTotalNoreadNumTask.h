/*
 * HttpGetTotalNoreadNumTask.h
 *
 *  Created on: 2018-6-22
 *      Author: Alex
 *        desc: 6.17.获取私信消息列表
 */

#ifndef HttpGetTotalNoreadNumTask_H_
#define HttpGetTotalNoreadNumTask_H_

#include "HttpRequestTask.h"
#include "item/HttpMainNoReadNumItem.h"

class HttpGetTotalNoreadNumTask;

class IRequestGetTotalNoreadNumCallback {
public:
	virtual ~IRequestGetTotalNoreadNumCallback(){};
	virtual void OnGetTotalNoreadNum(HttpGetTotalNoreadNumTask* task, bool success, int errnum, const string& errmsg, const HttpMainNoReadNumItem& item) = 0;
};
      
class HttpGetTotalNoreadNumTask : public HttpRequestTask {
public:
	HttpGetTotalNoreadNumTask();
	virtual ~HttpGetTotalNoreadNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetTotalNoreadNumCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetTotalNoreadNumCallback* mpCallback;

};

#endif /* HttpGetTotalNoreadNumTask_H_ */
