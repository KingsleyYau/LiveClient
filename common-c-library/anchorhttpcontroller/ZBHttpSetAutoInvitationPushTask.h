/*
 * ZBHttpSetAutoInvitationPushTask.h
 *
 *  Created on: 2019-11-22
 *      Author: Alex
 *        desc: 3.10.设置主播公开直播间自动邀请状态
 */

#ifndef ZBHttpSetAutoInvitationPushTask_H_
#define ZBHttpSetAutoInvitationPushTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpSetAutoInvitationPushTask;

class IRequestZBSetAutoInvitationPushCallback {
public:
	virtual ~IRequestZBSetAutoInvitationPushCallback(){};
	virtual void OnZBSetAutoInvitationPush(ZBHttpSetAutoInvitationPushTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpSetAutoInvitationPushTask : public ZBHttpRequestTask {
public:
	ZBHttpSetAutoInvitationPushTask();
	virtual ~ZBHttpSetAutoInvitationPushTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBSetAutoInvitationPushCallback* pCallback);

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
	IRequestZBSetAutoInvitationPushCallback* mpCallback;
    // 处理结果
    ZBSetPushType    mStatus;

};

#endif /* ZBHttpSetAutoInvitationPushTask_H_ */
