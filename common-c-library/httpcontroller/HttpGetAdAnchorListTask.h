/*
 * HttpGetAdAnchorListTask.h
 *
 *  Created on: 2017-9-15
 *      Author: Alex
 *        desc: 6.4.获取QN广告列表
 */

#ifndef HttpGetAdAnchorListTask_H_
#define HttpGetAdAnchorListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLiveRoomInfoItem.h"

class HttpGetAdAnchorListTask;

class IRequestGetAdAnchorListCallback {
public:
	virtual ~IRequestGetAdAnchorListCallback(){};
	virtual void OnGetAdAnchorList(HttpGetAdAnchorListTask* task, bool success, int errnum, const string& errmsg, const AdItemList& list) = 0;
};
      
class HttpGetAdAnchorListTask : public HttpRequestTask {
public:
	HttpGetAdAnchorListTask();
	virtual ~HttpGetAdAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAdAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    int number
                  );
    
    // 客户段需要获取的数量
    int GetNumber();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAdAnchorListCallback* mpCallback;
    // 客户段需要获取的数量
    int mNumber;

 
};

#endif /* HttpGetAdAnchorListTask_H_ */
