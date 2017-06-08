/*
 * HttpGetLiveRoomAllFansListTask.h
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 3.5.获取直播间所有观众头像列表
 */

#ifndef HttpGetLiveRoomAllFansListTask_H_
#define HttpGetLiveRoomAllFansListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomViewerItem.h"

class HttpGetLiveRoomAllFansListTask;

class IRequestGetLiveRoomAllFansListCallback {
public:
	virtual ~IRequestGetLiveRoomAllFansListCallback(){};
	virtual void OnGetLiveRoomAllFansList(HttpGetLiveRoomAllFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem) = 0;
};

class HttpGetLiveRoomAllFansListTask : public HttpRequestTask {
public:
	HttpGetLiveRoomAllFansListTask();
	virtual ~HttpGetLiveRoomAllFansListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomAllFansListCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			       用户身份唯一标识
     * @param roomId			   直播间ID
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                  string token,
                  string roomId,
                  int start,
                  int step
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取直播间ID
     */
    const string& GetRoomId();
    
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
	IRequestGetLiveRoomAllFansListCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 直播间ID
    string mRoomId;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
};

#endif /* HttpGetLiveRoomAllFansListTask_H_ */
