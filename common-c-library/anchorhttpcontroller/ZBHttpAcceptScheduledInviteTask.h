/*
 * ZBHttpAcceptScheduledInviteTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.2.主播接受预约(邀请主播接受观众发起的预约邀请)
 */

#ifndef ZBHttpAcceptScheduledInviteTask_H_
#define ZBHttpAcceptScheduledInviteTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpAcceptScheduledInviteTask;

class IRequestZBAcceptScheduledInviteCallback {
public:
	virtual ~IRequestZBAcceptScheduledInviteCallback(){};
	virtual void OnZBAcceptScheduledInvite(ZBHttpAcceptScheduledInviteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpAcceptScheduledInviteTask : public ZBHttpRequestTask {
public:
	ZBHttpAcceptScheduledInviteTask();
	virtual ~ZBHttpAcceptScheduledInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBAcceptScheduledInviteCallback* pCallback);

    /**
     * @param inviteId			       邀请ID
     */
    void SetParam(
                    string inviteId
                  );
    
    /**
     * 邀请ID
     */
    string GetInviteId();

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBAcceptScheduledInviteCallback* mpCallback;
    // 邀请ID
    string mInviteId;
    
};

#endif /* ZBHttpAcceptScheduledInviteTask_H_ */
