/*
 * HttpHandleBookingTask.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.2.观众处理预约邀请
 */

#ifndef HttpHandleBookingTask_H_
#define HttpHandleBookingTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpHandleBookingTask;

class IRequestHandleBookingCallback {
public:
	virtual ~IRequestHandleBookingCallback(){};
	virtual void OnHandleBooking(HttpHandleBookingTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpHandleBookingTask : public HttpRequestTask {
public:
	HttpHandleBookingTask();
	virtual ~HttpHandleBookingTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestHandleBookingCallback* pCallback);

    /**
     * @param inviteId			       邀请ID
     * @param isConfirm			       是否同意（0:否 1:是）
     */
    void SetParam(
                    string inviteId,
                    bool isConfirm
                  );
    
    /**
     * 邀请ID
     */
    string GetInviteId();
    /**
     * 是否同意（0:否 1:是）
     */
    bool GetIsConfirm();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestHandleBookingCallback* mpCallback;
    // 邀请ID
    string mInviteId;
    // 是否同意（0:否 1:是）
    bool mIsConfirm;
    
};

#endif /* HttpHandleBookingTask_H_ */
