/*
 * HttpUpQnInviteIdTask.h
 *
 *  Created on: 2019-07-29
 *      Author: Alex
 *        desc: 6.23.qn邀请弹窗更新邀请id
 */

#ifndef HttpUpQnInviteIdTask_H_
#define HttpUpQnInviteIdTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpUpQnInviteIdTask;

class IRequestUpQnInviteIdCallback {
public:
	virtual ~IRequestUpQnInviteIdCallback(){};
	virtual void OnUpQnInviteId(HttpUpQnInviteIdTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpUpQnInviteIdTask : public HttpRequestTask {
public:
	HttpUpQnInviteIdTask();
	virtual ~HttpUpQnInviteIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUpQnInviteIdCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    string manId,
                    string anchorId,
                    string inviteId,
                    string roomId,
                    LSBubblingInviteType inviteType
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUpQnInviteIdCallback* mpCallback;

};

#endif /* HttpUpQnInviteIdTask_H_ */
