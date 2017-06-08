/*
 * HttpCloseLiveRoomTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.3.关闭直播间
 */

#ifndef HttpCloseLiveRoomTask_H_
#define HttpCloseLiveRoomTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpCloseLiveRoomTask;

class IRequestCloseLiveRoomCallback {
public:
	virtual ~IRequestCloseLiveRoomCallback(){};
	virtual void OnCloseLiveRoom(HttpCloseLiveRoomTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpCloseLiveRoomTask : public HttpRequestTask {
public:
	HttpCloseLiveRoomTask();
	virtual ~HttpCloseLiveRoomTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCloseLiveRoomCallback* pCallback);

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
	IRequestCloseLiveRoomCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 直播间ID
    string mRoomId;
};

#endif /* HttpCloseLiveRoomTask_H_ */
