/*
 * HttpSendCancelPrivateLiveInviteTask.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *        desc: 4.3.取消预约邀请
 */

#ifndef HttpSendCancelPrivateLiveInviteTask_H_
#define HttpSendCancelPrivateLiveInviteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSendCancelPrivateLiveInviteTask;

class IRequestSendCancelPrivateLiveInviteCallback {
public:
	virtual ~IRequestSendCancelPrivateLiveInviteCallback(){};
	virtual void OnSendCancelPrivateLiveInvite(HttpSendCancelPrivateLiveInviteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSendCancelPrivateLiveInviteTask : public HttpRequestTask {
public:
	HttpSendCancelPrivateLiveInviteTask();
	virtual ~HttpSendCancelPrivateLiveInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendCancelPrivateLiveInviteCallback* pCallback);

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
	IRequestSendCancelPrivateLiveInviteCallback* mpCallback;
    // 邀请ID
    string mInvitationId;
    
};

#endif /* HttpSendCancelPrivateLiveInviteTask_H_ */
