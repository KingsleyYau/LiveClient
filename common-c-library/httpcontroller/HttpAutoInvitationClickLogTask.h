/*
 * HttpAutoInvitationClickLogTask.h
 *
 *  Created on: 2019-1-22
 *      Author: Alex
 *        desc: 8.10.自动邀请hangout点击记录
 */

#ifndef HttpAutoInvitationClickLogTask_H_
#define HttpAutoInvitationClickLogTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpAutoInvitationClickLogTask;

class IRequestAutoInvitationClickLogCallback {
public:
	virtual ~IRequestAutoInvitationClickLogCallback(){};
	virtual void OnAutoInvitationClickLog(HttpAutoInvitationClickLogTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpAutoInvitationClickLogTask : public HttpRequestTask {
public:
	HttpAutoInvitationClickLogTask();
	virtual ~HttpAutoInvitationClickLogTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAutoInvitationClickLogCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& anchorId,
                  bool isAuto
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAutoInvitationClickLogCallback* mpCallback;

};

#endif /* HttpAutoInvitationClickLogTask_H_ */
