/*
 * HttpGetAllSayHiListTask.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *        desc: 14.5.获取Say Hi的All列表
 */

#ifndef HttpGetAllSayHiListTask_H_
#define HttpGetAllSayHiListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpAllSayHiListItem.h"

class HttpGetAllSayHiListTask;

class IRequestGetAllSayHiListCallback {
public:
	virtual ~IRequestGetAllSayHiListCallback(){};
	virtual void OnGetAllSayHiList(HttpGetAllSayHiListTask* task, bool success, int errnum, const string& errmsg, const HttpAllSayHiListItem& item) = 0;
};
      
class HttpGetAllSayHiListTask : public HttpRequestTask {
public:
	HttpGetAllSayHiListTask();
	virtual ~HttpGetAllSayHiListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAllSayHiListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    int start,
                    int step
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAllSayHiListCallback* mpCallback;

};

#endif /* HttpGetAllSayHiListTask_H_ */
