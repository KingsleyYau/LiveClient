/*
 * HttpGetAnchorListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.1.获取Hot列表
 */

#ifndef HttpGetAnchorListTask_H_
#define HttpGetAnchorListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomInfoItem.h"

class HttpGetAnchorListTask;

class IRequestGetAnchorListCallback {
public:
	virtual ~IRequestGetAnchorListCallback(){};
	virtual void OnGetAnchorList(HttpGetAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) = 0;
};

class HttpGetAnchorListTask : public HttpRequestTask {
public:
	HttpGetAnchorListTask();
	virtual ~HttpGetAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAnchorListCallback* pCallback);

    /**
     * 
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                  int start,
                  int step
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取起始，用于分页，表示从第几个元素开始获取
     */
    int GetStart();
    /**
     * 步长，用于分页，表示本次请求获取多少个元素
     */
    int GetStep();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAnchorListCallback* mpCallback;
    
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* HttpGetAnchorListTask_H_ */
