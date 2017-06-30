/*
 * HttpGetLiveRoomGiftListByUserIdTask.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）
 */

#ifndef HttpGetLiveRoomGiftListByUserIdTask_H_
#define HttpGetLiveRoomGiftListByUserIdTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

typedef list<string> GiftWithIdItemList;
class HttpGetLiveRoomGiftListByUserIdTask;

class IRequestGetLiveRoomGiftListByUserIdCallback {
public:
	virtual ~IRequestGetLiveRoomGiftListByUserIdCallback(){};
	virtual void OnGetLiveRoomGiftListByUserId(HttpGetLiveRoomGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList) = 0;
};

class HttpGetLiveRoomGiftListByUserIdTask : public HttpRequestTask {
public:
	HttpGetLiveRoomGiftListByUserIdTask();
	virtual ~HttpGetLiveRoomGiftListByUserIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomGiftListByUserIdCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
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
	IRequestGetLiveRoomGiftListByUserIdCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 直播间ID
    string mRoomId;

};

#endif /* HttpGetLiveRoomGiftListByUserIdTask_H_ */
