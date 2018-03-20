/*
 * ZBHttpSetAutoPushTask.h
 *
 *  Created on: 2018-3-9
 *      Author: Alex
 *        desc: 3.8.设置主播公开直播间自动邀请状态
 */

#ifndef ZBHttpSetAutoPushTask_H_
#define ZBHttpSetAutoPushTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpSetAutoPushTask;

class IRequestZBSetAutoPushCallback {
public:
	virtual ~IRequestZBSetAutoPushCallback(){};
	virtual void OnZBSetAutoPush(ZBHttpSetAutoPushTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpSetAutoPushTask : public ZBHttpRequestTask {
public:
	ZBHttpSetAutoPushTask();
	virtual ~ZBHttpSetAutoPushTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBSetAutoPushCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    ZBSetPushType status
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBSetAutoPushCallback* mpCallback;
    // 处理结果
    ZBSetPushType    mStatus;

};

#endif /* ZBHttpSetAutoPushTask_H_ */
