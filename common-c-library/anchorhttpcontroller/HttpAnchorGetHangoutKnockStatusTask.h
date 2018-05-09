/*
 * HttpAnchorGetHangoutKnockStatusTask.h
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.6.获取敲门状态
 */

#ifndef HttpAnchorGetHangoutKnockStatusTask_H_
#define HttpAnchorGetHangoutKnockStatusTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"


class HttpAnchorGetHangoutKnockStatusTask;

class IRequestAnchorGetHangoutKnockStatusCallback {
public:
	virtual ~IRequestAnchorGetHangoutKnockStatusCallback(){};
	virtual void OnAnchorGetHangoutKnockStatus(HttpAnchorGetHangoutKnockStatusTask* task, bool success, int errnum, const string& errmsg, const string& roomId, AnchorMultiKnockType status, int expire) = 0;
};
      
class HttpAnchorGetHangoutKnockStatusTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetHangoutKnockStatusTask();
	virtual ~HttpAnchorGetHangoutKnockStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetHangoutKnockStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& knockId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorGetHangoutKnockStatusCallback* mpCallback;
    // 敲门ID
    string mKnockId;


};

#endif /* HttpAnchorGetHangoutKnockStatusTask_H */
