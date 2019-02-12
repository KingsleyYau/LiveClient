/*
 * HttpGetEmfListTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.3.获取信件列表
 */

#ifndef HttpGetEmfListTask_H_
#define HttpGetEmfListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLetterListItem.h"

class HttpGetEmfListTask;

class IRequestGetEmfListCallback {
public:
	virtual ~IRequestGetEmfListCallback(){};
	virtual void OnGetEmfList(HttpGetEmfListTask* task, bool success, int errnum, const string& errmsg, const HttpLetterItemList& letterList) = 0;
};
      
class HttpGetEmfListTask : public HttpRequestTask {
public:
	HttpGetEmfListTask();
	virtual ~HttpGetEmfListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetEmfListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSEMFType   type,
                    LSLetterTag tag,
                    int start,
                    int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetEmfListCallback* mpCallback;

};

#endif /* HttpGetEmfListTask_H_ */
