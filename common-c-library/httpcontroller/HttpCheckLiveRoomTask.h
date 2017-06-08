/*
 * HttpCheckLiveRoomTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.2.获取本人正在直播的直播间信息
 */

#ifndef HttpCheckLiveRoomTask_H_
#define HttpCheckLiveRoomTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpCheckLiveRoomTask;

class IRequestCheckLiveRoomCallback {
public:
	virtual ~IRequestCheckLiveRoomCallback(){};
	virtual void OnCheckLiveRoom(HttpCheckLiveRoomTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl) = 0;
};

class HttpCheckLiveRoomTask : public HttpRequestTask {
public:
	HttpCheckLiveRoomTask();
	virtual ~HttpCheckLiveRoomTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCheckLiveRoomCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
     */
    void SetParam(
                  string token
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestCheckLiveRoomCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    
    // 直播间ID
    string mRoomId;
    // 直播间流媒体服务url（如rtmp://192.168.88.17/live/samson_1）
    string mRoomUrl;
};

#endif /* HttpCheckLiveRoomTask_H_ */
