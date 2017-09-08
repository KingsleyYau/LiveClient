/*
 * HttpGetConfigTask.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 6.1.同步配置
 */

#ifndef HttpGetConfigTask_H_
#define HttpGetConfigTask_H_

#include "HttpRequestTask.h"

#include "item/HttpConfigItem.h"

class HttpGetConfigTask;

class IRequestGetConfigCallback {
public:
	virtual ~IRequestGetConfigCallback(){};
	virtual void OnGetConfig(HttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const HttpConfigItem& configItem) = 0;
};
      
class HttpGetConfigTask : public HttpRequestTask {
public:
	HttpGetConfigTask();
	virtual ~HttpGetConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetConfigCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetConfigCallback* mpCallback;

};

#endif /* HttpGiftListTask_H_ */
