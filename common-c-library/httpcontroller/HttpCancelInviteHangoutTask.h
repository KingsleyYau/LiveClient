/*
 * HttpCancelInviteHangoutTask.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *        desc: 8.3.取消多人互动邀请
 */

#ifndef HttpCancelInviteHangoutTask_H_
#define HttpCancelInviteHangoutTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpCancelInviteHangoutTask;

class IRequestCancelInviteHangoutCallback {
public:
	virtual ~IRequestCancelInviteHangoutCallback(){};
	virtual void OnCancelInviteHangout(HttpCancelInviteHangoutTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpCancelInviteHangoutTask : public HttpRequestTask {
public:
	HttpCancelInviteHangoutTask();
	virtual ~HttpCancelInviteHangoutTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCancelInviteHangoutCallback* pCallback);

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
	IRequestCancelInviteHangoutCallback* mpCallback;
   
    string mInviteId;         // 邀请ID

};

#endif /* HttpCancelInviteHangoutTask_H_ */
