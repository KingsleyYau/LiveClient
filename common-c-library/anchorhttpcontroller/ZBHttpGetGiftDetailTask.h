/*
 * ZBHttpGetGiftDetailTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 3.5.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）
 */

#ifndef ZBHttpGetGiftDetailTask_H_
#define ZBHttpGetGiftDetailTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBHttpLoginProtocol.h"

#include "ZBitem/ZBHttpGiftInfoItem.h"

class ZBHttpGetGiftDetailTask;

class IRequestZBGetGiftDetailCallback {
public:
	virtual ~IRequestZBGetGiftDetailCallback(){};
	virtual void OnZBGetGiftDetail(ZBHttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftInfoItem& item) = 0;
};

class ZBHttpGetGiftDetailTask : public ZBHttpRequestTask {
public:
	ZBHttpGetGiftDetailTask();
	virtual ~ZBHttpGetGiftDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetGiftDetailCallback* pCallback);

    /**
     *
     * @param giftId               礼物ID
     */
    void SetParam(
                  string giftId
                  );
    
    /**
     * 获取直播间ID
     */
    const string& GetGiftId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetGiftDetailCallback* mpCallback;

    // 礼物ID
    string mGiftId;

};

#endif /* ZBHttpGetGiftDetailTask_H_ */
