/*
 * ZBHttpDealTalentRequestTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 3.7.主播回复才艺点播邀请（用于主播接受/拒绝观众发出的才艺点播邀请）
 */

#ifndef ZBHttpDealTalentRequestTask_H_
#define ZBHttpDealTalentRequestTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpRequestEnum.h"
#include "ZBHttpLoginProtocol.h"

class ZBHttpDealTalentRequestTask;

class IRequestZBDealTalentRequestCallback {
public:
	virtual ~IRequestZBDealTalentRequestCallback(){};
    virtual void OnZBDealTalentRequest(ZBHttpDealTalentRequestTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class ZBHttpDealTalentRequestTask : public ZBHttpRequestTask {
public:
	ZBHttpDealTalentRequestTask();
	virtual ~ZBHttpDealTalentRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBDealTalentRequestCallback* pCallback);

    /**
     * 
     */
    void SetParam(
                  const string talentInviteId,
                  ZBTalentReplyType status
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBDealTalentRequestCallback* mpCallback;
    
    // 才艺点播邀请ID
    string mTalentInviteId;
    // 处理结果（1：同意，2：拒绝）
    ZBTalentReplyType mStatus;

};

#endif /* ZBHttpDealTalentRequestTask_H_ */
