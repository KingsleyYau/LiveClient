/*
 * HttpLiveFansListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.4.获取直播间观众头像列表
 */

#ifndef HttpLiveFansListTask_H_
#define HttpLiveFansListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveFansItem.h"

class HttpLiveFansListTask;

class IRequestLiveFansListCallback {
public:
	virtual ~IRequestLiveFansListCallback(){};
	virtual void OnLiveFansList(HttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const HttpLiveFansList& listItem) = 0;
};

class HttpLiveFansListTask : public HttpRequestTask {
public:
	HttpLiveFansListTask();
	virtual ~HttpLiveFansListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestLiveFansListCallback* pCallback);

    /**
     *
     * @param liveRoomId                直播场次ID
     * @param start                     起始，用于分页，表示从第几个元素开始获取
     * @param step                      步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                  string liveRoomId,
                  int start,
                  int step
                  );
    
    /**
     * 获取直播场次ID
     */
    const string& GetLiveRoomId();
    /**
     * 起始，用于分页，表示从第几个元素开始获取
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
	IRequestLiveFansListCallback* mpCallback;
    
    // 直播场次ID
    string mLiveRoomId;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* HttpLiveFansListTask_H_ */
