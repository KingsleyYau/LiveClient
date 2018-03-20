/*
 * ZBHttpRejectInstanceInviteTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.7.主播拒绝立即私密邀请(用于主播拒绝观众发送的立即私密邀请)
 */

#ifndef ZBHttpRejectInstanceInviteTask_H_
#define ZBHttpRejectInstanceInviteTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpRejectInstanceInviteTask;

class IRequestZBRejectInstanceInviteCallback {
public:
	virtual ~IRequestZBRejectInstanceInviteCallback(){};
	virtual void OnZBRejectInstanceInvite(ZBHttpRejectInstanceInviteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpRejectInstanceInviteTask : public ZBHttpRequestTask {
public:
	ZBHttpRejectInstanceInviteTask();
	virtual ~ZBHttpRejectInstanceInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBRejectInstanceInviteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& InviteId,
                    const string& rejectReason
                  );
    
    // 邀请ID
    const string& GetInviteId();
    // 拒绝理由（可无）
    const string& GetRejectReason();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBRejectInstanceInviteCallback* mpCallback;
    // 邀请ID
    string mInviteId;
    // RejectReason
    string mRejectReason;

};

#endif /* ZBHttpRejectInstanceInviteTask_H_ */
