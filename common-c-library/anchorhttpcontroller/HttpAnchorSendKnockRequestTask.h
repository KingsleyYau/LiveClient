/*
 * HttpAnchorSendKnockRequestTask.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.5.发起敲门请求
 */

#ifndef HttpAnchorSendKnockRequestTask_H_
#define HttpAnchorSendKnockRequestTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"


class HttpAnchorSendKnockRequestTask;

class IRequestAnchorSendKnockRequestCallback {
public:
	virtual ~IRequestAnchorSendKnockRequestCallback(){};
	virtual void OnAnchorSendKnockRequest(HttpAnchorSendKnockRequestTask* task, bool success, int errnum, const string& errmsg, const string& knockId, int expire) = 0;
};
      
class HttpAnchorSendKnockRequestTask : public ZBHttpRequestTask {
public:
	HttpAnchorSendKnockRequestTask();
	virtual ~HttpAnchorSendKnockRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorSendKnockRequestCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& roomId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorSendKnockRequestCallback* mpCallback;
    // 多人互动直播间ID
    string mRoomId;


};

#endif /* HttpAnchorSendKnockRequestTask_H */
