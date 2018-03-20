/*
 * ZBHttpAcceptInstanceInviteTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.6.主播接受立即私密邀请(用于主播接受观众发送的立即私密邀请)
 */

#ifndef ZBHttpAcceptInstanceInviteTask_H_
#define ZBHttpAcceptInstanceInviteTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpAcceptInstanceInviteTask;

class IRequestZBAcceptInstanceInviteCallback {
public:
	virtual ~IRequestZBAcceptInstanceInviteCallback(){};
	virtual void OnZBAcceptInstanceInvite(ZBHttpAcceptInstanceInviteTask* task, bool success, int errnum, const string& errmsg, const string& roomId, ZBHttpRoomType roomType) = 0;
};
      
class ZBHttpAcceptInstanceInviteTask : public ZBHttpRequestTask {
public:
	ZBHttpAcceptInstanceInviteTask();
	virtual ~ZBHttpAcceptInstanceInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBAcceptInstanceInviteCallback* pCallback);

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
	IRequestZBAcceptInstanceInviteCallback* mpCallback;
    // 邀请ID
    string mInviteId;

};

#endif /* ZBHttpAcceptInstanceInviteTask_H_ */
