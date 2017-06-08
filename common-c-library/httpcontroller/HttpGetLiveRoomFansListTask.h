/*
 * HttpGetLiveRoomFansListTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.4.获取直播间观众头像列表（限定数量）
 */

#ifndef HttpGetLiveRoomFansListTask_H_
#define HttpGetLiveRoomFansListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomViewerItem.h"

class HttpGetLiveRoomFansListTask;

class IRequestGetLiveRoomFansListCallback {
public:
	virtual ~IRequestGetLiveRoomFansListCallback(){};
	virtual void OnGetLiveRoomFansList(HttpGetLiveRoomFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem) = 0;
};

class HttpGetLiveRoomFansListTask : public HttpRequestTask {
public:
	HttpGetLiveRoomFansListTask();
	virtual ~HttpGetLiveRoomFansListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomFansListCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			       用户身份唯一标识
     * @param roomId			   直播间ID
     */
    void SetParam(
                  string token,
                  string roomId
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取直播间ID
     */
    const string& GetRoomId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveRoomFansListCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 直播间ID
    string mRoomId;
};

#endif /* HttpGetLiveRoomFansListTask_H_ */
