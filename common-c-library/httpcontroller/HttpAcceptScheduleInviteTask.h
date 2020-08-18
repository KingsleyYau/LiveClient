/*
 * HttpAcceptScheduleInviteTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.4.接受预付费直播邀请
 */

#ifndef HttpAcceptScheduleInviteTask_H_
#define HttpAcceptScheduleInviteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"


class HttpAcceptScheduleInviteTask;

class IRequestAcceptScheduleInviteCallback {
public:
	virtual ~IRequestAcceptScheduleInviteCallback(){};
	virtual void OnAcceptScheduleInvite(HttpAcceptScheduleInviteTask* task, bool success, int errnum, const string& errmsg, long long starusUpdateTime, int duration) = 0;
};
      
class HttpAcceptScheduleInviteTask : public HttpRequestTask {
public:
	HttpAcceptScheduleInviteTask();
	virtual ~HttpAcceptScheduleInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAcceptScheduleInviteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string inviteId,
                  int duration
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAcceptScheduleInviteCallback* mpCallback;
    int mduration;

};

#endif /* HttpAcceptScheduleInviteTask_H */
