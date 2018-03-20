/*
 * ZBHttpCancelInstantInviteUserTask.h
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 4.8.主播取消已发的立即私密邀请
 */

#ifndef ZBHttpCancelInstantInviteUserTask_H_
#define ZBHttpCancelInstantInviteUserTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpCancelInstantInviteUserTask;

class IRequestZBCancelInstantInviteUserCallback {
public:
	virtual ~IRequestZBCancelInstantInviteUserCallback(){};
	virtual void OnZBCancelInstantInviteUser(ZBHttpCancelInstantInviteUserTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpCancelInstantInviteUserTask : public ZBHttpRequestTask {
public:
	ZBHttpCancelInstantInviteUserTask();
	virtual ~ZBHttpCancelInstantInviteUserTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBCancelInstantInviteUserCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& InviteId
                  );
    
    // 邀请ID
    const string& GetInviteId();

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBCancelInstantInviteUserCallback* mpCallback;
    // 邀请ID
    string mInviteId;

};

#endif /* ZBHttpCancelInstantInviteUserTask_H_ */
