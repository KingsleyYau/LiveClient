/*
 * HttpAcceptInstanceInviteTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 4.7.观众处理立即私密邀请
 */

#ifndef HttpAcceptInstanceInviteTask_H_
#define HttpAcceptInstanceInviteTask_H_

#include "HttpRequestTask.h"
#include "item/HttpAcceptInstanceInviteItem.h"

class HttpAcceptInstanceInviteTask;

class IRequestAcceptInstanceInviteCallback {
public:
	virtual ~IRequestAcceptInstanceInviteCallback(){};
	virtual void OnAcceptInstanceInvite(HttpAcceptInstanceInviteTask* task, bool success, int errnum, const string& errmsg, const HttpAcceptInstanceInviteItem& item) = 0;
};
      
class HttpAcceptInstanceInviteTask : public HttpRequestTask {
public:
	HttpAcceptInstanceInviteTask();
	virtual ~HttpAcceptInstanceInviteTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAcceptInstanceInviteCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& InviteId,
                    bool isConfirm
                  );
    
    // 邀请ID
    const string& GetInviteId();
    // 是否同意（0: 否， 1: 是）
    bool GetIsConfirm();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAcceptInstanceInviteCallback* mpCallback;
    // 邀请ID
    string mInviteId;
    // 是否同意（0: 否， 1: 是）
    bool mIsConfirm;


};

#endif /* HttpAcceptInstanceInviteTask_H_ */
