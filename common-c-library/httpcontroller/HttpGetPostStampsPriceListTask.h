/*
 * HttpGetPostStampsPriceListTask.h
 *
 *  Created on: 2020-6-29
 *      Author: Alex
 *        desc: 7.9.获取我司邮票产品列表
 */

#ifndef HttpGetPostStampsPriceListTask_H_
#define HttpGetPostStampsPriceListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPostStampsPriceItem.h"


class HttpGetPostStampsPriceListTask;

class IRequestGetPostStampsPriceListCallback {
public:
	virtual ~IRequestGetPostStampsPriceListCallback(){};
	virtual void OnGetPostStampsPriceList(HttpGetPostStampsPriceListTask* task, bool success, int errnum, const string& errmsg, const PostStampsPriceList& list) = 0;
};
      
class HttpGetPostStampsPriceListTask : public HttpRequestTask {
public:
	HttpGetPostStampsPriceListTask();
	virtual ~HttpGetPostStampsPriceListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPostStampsPriceListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPostStampsPriceListCallback* mpCallback;
    int mduration;

};

#endif /* HttpGetPostStampsPriceListTask_H */
