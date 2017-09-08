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
     * @param page                  页数（可无，无则表示获取所有）
     * @param number                每页的元素数量（可无，无则表示获取所有）
     */
    void SetParam(
                  string liveRoomId,
                  int page,
                  int number
                  );
    
    /**
     * 获取直播场次ID
     */
    const string& GetLiveRoomId();
    /**
     * 页数（可无，无则表示获取所有）
     */
    int GetPage();
    /**
     * 每页的元素数量（可无，无则表示获取所有）
     */
    int GetNumber();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestLiveFansListCallback* mpCallback;
    
    // 直播场次ID
    string mLiveRoomId;
    // 页数（可无，无则表示获取所有）
    int mPage;
    // 每页的元素数量（可无，无则表示获取所有）
    int mNumber;
};

#endif /* HttpLiveFansListTask_H_ */
