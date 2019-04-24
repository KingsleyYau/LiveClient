/*
 * HttpGetResponseSayHiListTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.6.Waiting for your reply列表
 */

#ifndef HttpGetResponseSayHiListTask_H_
#define HttpGetResponseSayHiListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpResponseSayHiListItem.h"
#include "HttpRequestEnum.h"

class HttpGetResponseSayHiListTask;

class IRequestGetResponseSayHiListCallback {
public:
	virtual ~IRequestGetResponseSayHiListCallback(){};
	virtual void OnGetResponseSayHiList(HttpGetResponseSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpResponseSayHiListItem& item) = 0;
};
      
class HttpGetResponseSayHiListTask : public HttpRequestTask {
public:
	HttpGetResponseSayHiListTask();
	virtual ~HttpGetResponseSayHiListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetResponseSayHiListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    LSSayHiListType type,
                    int start,
                    int step
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetResponseSayHiListCallback* mpCallback;
};

#endif /* HttpGetResponseSayHiListTask_H_ */
