/*
 * ZBHttpGiftListTask.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.4.获取主播直播间礼物列表
 */

#ifndef ZBHttpGiftListTask_H_
#define ZBHttpGiftListTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpGiftLimitNumItem.h"

class ZBHttpGiftListTask;

class IRequestZBGiftListCallback {
public:
	virtual ~IRequestZBGiftListCallback(){};
	virtual void OnZBGiftList(ZBHttpGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftLimitNumItemList& itemList) = 0;
};

class ZBHttpGiftListTask : public ZBHttpRequestTask {
public:
	ZBHttpGiftListTask();
	virtual ~ZBHttpGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGiftListCallback* pCallback);

    /**
     *  roomId      直播间ID
     */
    void SetParam( const string roomId
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGiftListCallback* mpCallback;
    // 直播间ID
    string mRoomId;

};

#endif /* ZBHttpGetAllGiftListTask_H_ */
