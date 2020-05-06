/*
 * HttpGetScheduleInviteListTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.7.获取预付费直播邀请列表
 */

#ifndef HttpGetScheduleInviteListTask_H_
#define HttpGetScheduleInviteListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpScheduleInviteListItem.h"


class HttpGetScheduleInviteListTask;

class IRequestGetScheduleInviteListCallback {
public:
	virtual ~IRequestGetScheduleInviteListCallback(){};
	virtual void OnGetScheduleInviteList(HttpGetScheduleInviteListTask* task, bool success, int errnum, const string& errmsg, const ScheduleInviteList& list) = 0;
};
      
class HttpGetScheduleInviteListTask : public HttpRequestTask {
public:
	HttpGetScheduleInviteListTask();
	virtual ~HttpGetScheduleInviteListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetScheduleInviteListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  LSScheduleInviteStatus status,
                  LSScheduleSendFlagType sendFlag,
                  string anchorId,
                  int start,
                  int step
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetScheduleInviteListCallback* mpCallback;

};

#endif /* HttpGetScheduleInviteListTask_H */
