/*
 * HttpGetGiftDetailTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）
 */

#ifndef HttpGetGiftDetailTask_H_
#define HttpGetGiftDetailTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

#include "item/HttpGiftInfoItem.h"

class HttpGetGiftDetailTask;

class IRequestGetGiftDetailCallback {
public:
	virtual ~IRequestGetGiftDetailCallback(){};
	virtual void OnGetGiftDetail(HttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpGiftInfoItem& item) = 0;
};

class HttpGetGiftDetailTask : public HttpRequestTask {
public:
	HttpGetGiftDetailTask();
	virtual ~HttpGetGiftDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetGiftDetailCallback* pCallback);

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
	IRequestGetGiftDetailCallback* mpCallback;

    // 礼物ID
    string mGiftId;

};

#endif /* HttpGetGiftDetailTask_H_ */
