/*
 * ZBHttpGetAllGiftListTask.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 3.3.获取礼物列表
 */

#ifndef ZBHttpGetAllGiftListTask_H_
#define ZBHttpGetAllGiftListTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpGiftInfoItem.h"

class ZBHttpGetAllGiftListTask;

class IRequestZBGetAllGiftListCallback {
public:
	virtual ~IRequestZBGetAllGiftListCallback(){};
	virtual void OnZBGetAllGiftList(ZBHttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBGiftItemList& itemList) = 0;
};

class ZBHttpGetAllGiftListTask : public ZBHttpRequestTask {
public:
	ZBHttpGetAllGiftListTask();
	virtual ~ZBHttpGetAllGiftListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetAllGiftListCallback* pCallback);

    /**
     * 
     */
    void SetParam(
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetAllGiftListCallback* mpCallback;

};

#endif /* ZBHttpGetAllGiftListTask_H_ */
