/*
 * HttpGetLoiDetailTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.2.获取意向信详情
 */

#ifndef HttpGetLoiDetailTask_H_
#define HttpGetLoiDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpDetailLoiItem.h"

class HttpGetLoiDetailTask;

class IRequestGetLoiDetailCallback {
public:
	virtual ~IRequestGetLoiDetailCallback(){};
	virtual void OnGetLoiDetail(HttpGetLoiDetailTask* task, bool success, int errnum, const string& errmsg, const HttpDetailLoiItem& detailLoiItem) = 0;
};
      
class HttpGetLoiDetailTask : public HttpRequestTask {
public:
	HttpGetLoiDetailTask();
	virtual ~HttpGetLoiDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLoiDetailCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    string loiId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLoiDetailCallback* mpCallback;

};

#endif /*HttpGetLoiDetailTask_H_ */
