/*
 * HttpGetScheduleInviteStatusTask.h
 *
 *  Created on: 2020-3-27
 *      Author: Alex
 *        desc: 17.10.获取预付费直播邀请状态
 */

#ifndef HttpGetScheduleInviteStatusTask_H_
#define HttpGetScheduleInviteStatusTask_H_

#include "HttpRequestTask.h"
#include "item/HttpScheduleInviteStatusItem.h"


class HttpGetScheduleInviteStatusTask;

class IRequestGetScheduleInviteStatusCallback {
public:
	virtual ~IRequestGetScheduleInviteStatusCallback(){};
	virtual void OnGetScheduleInviteStatus(HttpGetScheduleInviteStatusTask* task, bool success, int errnum, const string& errmsg, const HttpScheduleInviteStatusItem& item) = 0;
};
      
class HttpGetScheduleInviteStatusTask : public HttpRequestTask {
public:
	HttpGetScheduleInviteStatusTask();
	virtual ~HttpGetScheduleInviteStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetScheduleInviteStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(

                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetScheduleInviteStatusCallback* mpCallback;

};

#endif /* HttpGetScheduleInviteStatusTask_H */
