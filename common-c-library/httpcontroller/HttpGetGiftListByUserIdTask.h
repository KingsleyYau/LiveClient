/*
 * HttpGetGiftListByUserIdTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）
 */

#ifndef HttpGetGiftListByUserIdTask_H_
#define HttpGetGiftListByUserIdTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "item/HttpGiftWithIdItem.h"

class HttpGetGiftListByUserIdTask;

class IRequestGetGiftListByUserIdCallback {
public:
	virtual ~IRequestGetGiftListByUserIdCallback(){};
	virtual void OnGetGiftListByUserId(HttpGetGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList) = 0;
};

class HttpGetGiftListByUserIdTask : public HttpRequestTask {
public:
	HttpGetGiftListByUserIdTask();
	virtual ~HttpGetGiftListByUserIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetGiftListByUserIdCallback* pCallback);

    /**
     * @param roomId			      直播间ID
     */
    void SetParam(
                  string roomId
                  );
    
    /**
     * 获取直播间ID
     */
    const string& GetRoomId();
    
protected:
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetGiftListByUserIdCallback* mpCallback;
    
    // 直播间ID
    string mRoomId;

};

#endif /* HttpGetGiftListByUserIdTask_H_ */
