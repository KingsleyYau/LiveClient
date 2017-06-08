/*
 * HttpGetLiveRoomHotTask.h
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 3.6.获取Hot列表
 */

#ifndef HttpGetLiveRoomHotTask_H_
#define HttpGetLiveRoomHotTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomInfoItem.h"

class HttpGetLiveRoomHotTask;

class IRequestGetLiveRoomHotCallback {
public:
	virtual ~IRequestGetLiveRoomHotCallback(){};
	virtual void OnGetLiveRoomHot(HttpGetLiveRoomHotTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) = 0;
};

class HttpGetLiveRoomHotTask : public HttpRequestTask {
public:
	HttpGetLiveRoomHotTask();
	virtual ~HttpGetLiveRoomHotTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomHotCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			       用户身份唯一标识
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                  string token,
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
	IRequestGetLiveRoomHotCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* HttpGetLiveRoomHotTask_H_ */
