/*
 * ZBHttpGetScheduledAcceptNumTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)
 */

#ifndef ZBHttpGetScheduledAcceptNumTask_H_
#define ZBHttpGetScheduledAcceptNumTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpGetScheduledAcceptNumTask;

class IRequestZBGetScheduledAcceptNumCallback {
public:
	virtual ~IRequestZBGetScheduledAcceptNumCallback(){};
	virtual void OnZBGetScheduledAcceptNum(ZBHttpGetScheduledAcceptNumTask* task, bool success, int errnum, const string& errmsg, const int scheduledNum) = 0;
};
      
class ZBHttpGetScheduledAcceptNumTask : public ZBHttpRequestTask {
public:
	ZBHttpGetScheduledAcceptNumTask();
	virtual ~ZBHttpGetScheduledAcceptNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetScheduledAcceptNumCallback* pCallback);

    /**
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetScheduledAcceptNumCallback* mpCallback;
    
};

#endif /* ZBHttpGetScheduledAcceptNumTask_H_ */
