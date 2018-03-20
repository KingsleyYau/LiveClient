/*
 * ZBHttpRejectScheduledInviteTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)
 */

#ifndef ZBHttpRejectScheduledInviteTask_H_
#define ZBHttpRejectScheduledInviteTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpRejectScheduledInviteTask;

class IRequestZBRejectScheduledInviteCallback {
public:
	virtual ~IRequestZBRejectScheduledInviteCallback(){};
	virtual void OnZBRejectScheduledInvite(ZBHttpRejectScheduledInviteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpRejectScheduledInviteTask : public ZBHttpRequestTask {
public:
	ZBHttpRejectScheduledInviteTask();
	virtual ~ZBHttpRejectScheduledInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBRejectScheduledInviteCallback* pCallback);

    /**
     * @param invitationId			       邀请ID
     */
    void SetParam(
                    string invitationId
                  );
    
    /**
     * 邀请ID
     */
    string GetInvitationId();

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBRejectScheduledInviteCallback* mpCallback;
    // 邀请ID
    string mInvitationId;
    
};

#endif /* ZBHttpRejectScheduledInviteTask_H_ */
