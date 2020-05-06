/*
 * HttpGetScheduleInviteDetailTask.h
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.8.获取预付费直播邀请详情
 */

#ifndef HttpGetScheduleInviteDetailTask_H_
#define HttpGetScheduleInviteDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpScheduleInviteDetailItem.h"


class HttpGetScheduleInviteDetailTask;

class IRequestGetScheduleInviteDetailCallback {
public:
	virtual ~IRequestGetScheduleInviteDetailCallback(){};
	virtual void OnGetScheduleInviteDetail(HttpGetScheduleInviteDetailTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteDetailItem& item) = 0;
};
      
class HttpGetScheduleInviteDetailTask : public HttpRequestTask {
public:
	HttpGetScheduleInviteDetailTask();
	virtual ~HttpGetScheduleInviteDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetScheduleInviteDetailCallback* pCallback);

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
	IRequestGetScheduleInviteDetailCallback* mpCallback;

};

#endif /* HttpGetScheduleInviteDetailTask_H */
