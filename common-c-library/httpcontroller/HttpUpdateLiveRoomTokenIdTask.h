/*
 * HttpUpdateLiveRoomTokenIdTask.h
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 2.6.上传tokenid接口
 */

#ifndef HttpUpdateLiveRoomTokenIdTask_H_
#define HttpUpdateLiveRoomTokenIdTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

class HttpUpdateLiveRoomTokenIdTask;

class IRequestUpdateLiveRoomTokenIdCallback {
public:
	virtual ~IRequestUpdateLiveRoomTokenIdCallback(){};
	virtual void OnUpdateLiveRoomTokenId(HttpUpdateLiveRoomTokenIdTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpUpdateLiveRoomTokenIdTask : public HttpRequestTask {
public:
	HttpUpdateLiveRoomTokenIdTask();
	virtual ~HttpUpdateLiveRoomTokenIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUpdateLiveRoomTokenIdCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			           用户身份唯一标识
     * @param tokenId			       用于Push Notification的ID
     */
    void SetParam(
                  string token,
                  string tokenId
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取用于Push Notification的ID
     */
    const string& GetmTokenId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUpdateLiveRoomTokenIdCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 用于Push Notification的ID
    string mTokenId;

};

#endif /* HttpUpdateLiveRoomTokenIdTask_H_ */
