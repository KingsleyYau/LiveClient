/*
 * HttpGetLiveRoomAllGiftListTask.h
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
 */

#ifndef HttpGetLiveRoomAllGiftListTask_H_
#define HttpGetLiveRoomAllGiftListTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpLiveRoomGiftItem.h"

class HttpGetLiveRoomAllGiftListTask;

class IRequestGetLiveRoomAllGiftListCallback {
public:
	virtual ~IRequestGetLiveRoomAllGiftListCallback(){};
	virtual void OnGetLiveRoomAllGiftList(HttpGetLiveRoomAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList) = 0;
};

class HttpGetLiveRoomAllGiftListTask : public HttpRequestTask {
public:
	HttpGetLiveRoomAllGiftListTask();
	virtual ~HttpGetLiveRoomAllGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomAllGiftListCallback* pCallback);

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
	IRequestGetLiveRoomAllGiftListCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;

};

#endif /* HttpGetLiveRoomAllGiftListTask_H_ */
