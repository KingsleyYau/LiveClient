/*
 * HttpGetHangoutInvitStatusTask.h
 *
 *  Created on: 2018-4-13
 *      Author: Alex
 *        desc: 8.4.获取多人互动邀请状态
 */

#ifndef HttpGetHangoutInvitStatusTask_H_
#define HttpGetHangoutInvitStatusTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetHangoutInvitStatusTask;

class IRequestGetHangoutInvitStatusCallback {
public:
	virtual ~IRequestGetHangoutInvitStatusCallback(){};
	virtual void OnGetHangoutInvitStatus(HttpGetHangoutInvitStatusTask* task, bool success, int errnum, const string& errmsg, HangoutInviteStatus status, const string& roomId, int expire) = 0;
};
      
class HttpGetHangoutInvitStatusTask : public HttpRequestTask {
public:
	HttpGetHangoutInvitStatusTask();
	virtual ~HttpGetHangoutInvitStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetHangoutInvitStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& inviteId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetHangoutInvitStatusCallback* mpCallback;
   
    string mInviteId;         // 邀请ID

};

#endif /* HttpGetHangoutInvitStatusTask_H_ */
