/*
 * HttpCancelScheduleInviteTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.6.取消预付费直播邀请
 */

#ifndef HttpCancelScheduleInviteTask_H_
#define HttpCancelScheduleInviteTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"


class HttpCancelScheduleInviteTask;

class IRequestCancelScheduleInviteCallback {
public:
	virtual ~IRequestCancelScheduleInviteCallback(){};
	virtual void OnCancelScheduleInvite(HttpCancelScheduleInviteTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpCancelScheduleInviteTask : public HttpRequestTask {
public:
	HttpCancelScheduleInviteTask();
	virtual ~HttpCancelScheduleInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCancelScheduleInviteCallback* pCallback);

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
	IRequestCancelScheduleInviteCallback* mpCallback;

};

#endif /* HttpCancelScheduleInviteTask_H */
