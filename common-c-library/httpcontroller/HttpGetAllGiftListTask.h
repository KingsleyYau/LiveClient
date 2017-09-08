/*
 * HttpGetAllGiftListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
 */

#ifndef HttpGetAllGiftListTask_H_
#define HttpGetAllGiftListTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpGiftInfoItem.h"

class HttpGetAllGiftListTask;

class IRequestGetAllGiftListCallback {
public:
	virtual ~IRequestGetAllGiftListCallback(){};
	virtual void OnGetAllGiftList(HttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList) = 0;
};

class HttpGetAllGiftListTask : public HttpRequestTask {
public:
	HttpGetAllGiftListTask();
	virtual ~HttpGetAllGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAllGiftListCallback* pCallback);

    /**
     * 
     */
    void SetParam(
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAllGiftListCallback* mpCallback;


};

#endif /* HttpGetLiveRoomAllGiftListTask_H_ */
