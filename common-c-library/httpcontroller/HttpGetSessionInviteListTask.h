/*
 * HttpGetSessionInviteListTask.h
 *
 *  Created on: 2020-3-26
 *      Author: Alex
 *        desc: 17.9.获取某会话中预付费直播邀请列表
 */

#ifndef HttpGetSessionInviteListTask_H_
#define HttpGetSessionInviteListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLiveScheduleInviteItem.h"


class HttpGetSessionInviteListTask;

class IRequestGetSessionInviteListCallback {
public:
	virtual ~IRequestGetSessionInviteListCallback(){};
	virtual void OnGetSessionInviteList(HttpGetSessionInviteListTask* task, bool success, int errnum, const string& errmsg, const LiveScheduleInviteList& list) = 0;
};
      
class HttpGetSessionInviteListTask : public HttpRequestTask {
public:
	HttpGetSessionInviteListTask();
	virtual ~HttpGetSessionInviteListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetSessionInviteListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  LSScheduleInviteType type,
                  string refId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetSessionInviteListCallback* mpCallback;

};

#endif /* HttpGetSessionInviteListTask_H */
