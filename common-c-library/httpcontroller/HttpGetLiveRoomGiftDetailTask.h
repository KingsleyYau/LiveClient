/*
 * HttpGetLiveRoomGiftDetailTask.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
 */

#ifndef HttpGetLiveRoomGiftDetailTask_H_
#define HttpGetLiveRoomGiftDetailTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

#include "item/HttpLiveRoomGiftItem.h"

class HttpGetLiveRoomGiftDetailTask;

class IRequestGetLiveRoomGiftDetailCallback {
public:
	virtual ~IRequestGetLiveRoomGiftDetailCallback(){};
	virtual void OnGetLiveRoomGiftDetail(HttpGetLiveRoomGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomGiftItem& item) = 0;
};

class HttpGetLiveRoomGiftDetailTask : public HttpRequestTask {
public:
	HttpGetLiveRoomGiftDetailTask();
	virtual ~HttpGetLiveRoomGiftDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomGiftDetailCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
     * @param giftId               礼物ID
     */
    void SetParam(
                  string token,
                  string giftId
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();

    /**
     * 获取直播间ID
     */
    const string& GetGiftId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveRoomGiftDetailCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 礼物ID
    string mGiftId;

};

#endif /* HttpGetLiveRoomGiftDetailTask_H_ */
