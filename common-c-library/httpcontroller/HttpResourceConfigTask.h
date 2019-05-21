/*
 * HttpResourceConfigTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.1.获取发送SayHi的主题和文本信息（用于观众端获取发送SayHi的主题和文本信息）
 */

#ifndef HttpResourceConfigTask_H_
#define HttpResourceConfigTask_H_

#include "HttpRequestTask.h"
#include "item/HttpSayHiResourceConfigItem.h"

class HttpResourceConfigTask;

class IRequestResourceConfigCallback {
public:
	virtual ~IRequestResourceConfigCallback(){};
	virtual void OnResourceConfig(HttpResourceConfigTask* task, bool success, int errnum, const string& errmsg, const HttpSayHiResourceConfigItem& item) = 0;
};
      
class HttpResourceConfigTask : public HttpRequestTask {
public:
	HttpResourceConfigTask();
	virtual ~HttpResourceConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestResourceConfigCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestResourceConfigCallback* mpCallback;

};

#endif /* HttpResourceConfigTask_H_ */
