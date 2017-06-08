/*
 * HttpLiveRoomCreateTask.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 3.1.新建直播间
 */

#ifndef HttpLiveRoomCreateTask_H_
#define HttpLiveRoomCreateTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpLiveRoomCreateTask;

class IRequestLiveRoomCreateCallback {
public:
	virtual ~IRequestLiveRoomCreateCallback(){};
	virtual void OnCreateLiveRoom(HttpLiveRoomCreateTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl) = 0;
};

class HttpLiveRoomCreateTask : public HttpRequestTask {
public:
	HttpLiveRoomCreateTask();
	virtual ~HttpLiveRoomCreateTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestLiveRoomCreateCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
     * @param roomNmae			   直播间名称
     * @param roomPhotoId		   封面图ID

     */
    void SetParam(
                  string token,
                  string roomNmae,
                  string roomPhotoId
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取直播间名称
     */
    const string& GetRoomName();
    
    /**
     * 获取封面图ID
     */
    const string& GetRoomPhotoId();

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestLiveRoomCreateCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 直播间名称
    string mRoomName;
    // 封面图ID
    string mRoomPhotoId;
    
    // 直播间ID
    string mRoomId;
    // 直播间流媒体服务url（如rtmp://192.168.88.17/live/samson_1）
    string mRoomUrl;

};

#endif /* HttpLiveRoomCreateTask_H_ */
