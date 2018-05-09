/*
 * HttpAnchorCancelHangoutKnockTask.h
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *        desc: 6.7.取消敲门请求
 */

#ifndef HttpAnchorCancelHangoutKnockTask_H_
#define HttpAnchorCancelHangoutKnockTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"


class HttpAnchorCancelHangoutKnockTask;

class IRequestAnchorCancelHangoutKnockCallback {
public:
	virtual ~IRequestAnchorCancelHangoutKnockCallback(){};
	virtual void OnAnchorCancelHangoutKnock(HttpAnchorCancelHangoutKnockTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpAnchorCancelHangoutKnockTask : public ZBHttpRequestTask {
public:
	HttpAnchorCancelHangoutKnockTask();
	virtual ~HttpAnchorCancelHangoutKnockTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorCancelHangoutKnockCallback* pCallback);

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
	IRequestAnchorCancelHangoutKnockCallback* mpCallback;
    // 敲门ID
    string mKnockId;


};

#endif /* HttpAnchorCancelHangoutKnockTask_H */
