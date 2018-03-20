/*
 * ZBHttpLiveFansListTask.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.1.获取直播间观众列表
 */

#ifndef ZBHttpLiveFansListTask_H_
#define ZBHttpLiveFansListTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpLiveFansItem.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpLiveFansListTask;

class IRequestZBLiveFansListCallback {
public:
	virtual ~IRequestZBLiveFansListCallback(){};
	virtual void OnZBLiveFansList(ZBHttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansList& listItem) = 0;
};

class ZBHttpLiveFansListTask : public ZBHttpRequestTask {
public:
	ZBHttpLiveFansListTask();
	virtual ~ZBHttpLiveFansListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBLiveFansListCallback* pCallback);

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
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBLiveFansListCallback* mpCallback;
    
    string mLiveRoomId;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* ZBHttpLiveFansListTask_H_ */
