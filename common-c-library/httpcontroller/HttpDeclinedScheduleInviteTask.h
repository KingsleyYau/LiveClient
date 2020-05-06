/*
 * HttpDeclinedScheduleInviteTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.5.拒绝预付费直播邀请
 */

#ifndef HttpDeclinedScheduleInviteTask_H_
#define HttpDeclinedScheduleInviteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"


class HttpDeclinedScheduleInviteTask;

class IRequestDeclinedScheduleInviteCallback {
public:
	virtual ~IRequestDeclinedScheduleInviteCallback(){};
	virtual void OnDeclinedScheduleInvite(HttpDeclinedScheduleInviteTask* task, bool success, int errnum, const string& errmsg, long long starusUpdateTime) = 0;
};
      
class HttpDeclinedScheduleInviteTask : public HttpRequestTask {
public:
	HttpDeclinedScheduleInviteTask();
	virtual ~HttpDeclinedScheduleInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDeclinedScheduleInviteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string inviteId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestDeclinedScheduleInviteCallback* mpCallback;

};

#endif /* HttpDeclinedScheduleInviteTask_H */
