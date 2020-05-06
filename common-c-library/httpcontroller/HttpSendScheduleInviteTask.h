/*
 * HttpSendScheduleInviteTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.3.发送预付费直播邀请
 */

#ifndef HttpSendScheduleInviteTask_H_
#define HttpSendScheduleInviteTask_H_

#include "HttpRequestTask.h"
#include "item/HttpScheduleInviteItem.h"


class HttpSendScheduleInviteTask;

class IRequestSendScheduleInviteCallback {
public:
	virtual ~IRequestSendScheduleInviteCallback(){};
	virtual void OnSendScheduleInvite(HttpSendScheduleInviteTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteItem& item) = 0;
};
      
class HttpSendScheduleInviteTask : public HttpRequestTask {
public:
	HttpSendScheduleInviteTask();
	virtual ~HttpSendScheduleInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendScheduleInviteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  LSScheduleInviteType type,
                  string refId,
                  string anchorId,
                  string timeZoneId,
                  string startTime,
                  int duration
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendScheduleInviteCallback* mpCallback;

};

#endif /* HttpSendScheduleInviteTask_H */
