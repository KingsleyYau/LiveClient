/*
 * HttpGetFollowListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.2.获取Following列表
 */

#ifndef HttpGetFollowListTask_H_
#define HttpGetFollowListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpFollowItem.h"

class HttpGetFollowListTask;

class IRequestGetFollowListCallback {
public:
	virtual ~IRequestGetFollowListCallback(){};
	virtual void OnGetFollowList(HttpGetFollowListTask* task, bool success, int errnum, const string& errmsg, const FollowItemList& listItem) = 0;
};

class HttpGetFollowListTask : public HttpRequestTask {
public:
	HttpGetFollowListTask();
	virtual ~HttpGetFollowListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetFollowListCallback* pCallback);

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
	IRequestGetFollowListCallback* mpCallback;
    
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* HttpGetAnchorListTask_H_ */
