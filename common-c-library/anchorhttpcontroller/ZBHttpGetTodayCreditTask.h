/*
 * ZBHttpGetTodayCreditTask.h
 *
 *  Created on: 2018-3-1
 *      Author: Alex
 *        desc: 5.2.获取收入信息
 */

#ifndef ZBHttpGetTodayCreditTask_H_
#define ZBHttpGetTodayCreditTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpTodayCreditItem.h"

class ZBHttpGetTodayCreditTask;

class IRequestZBGetTodayCreditCallback {
public:
	virtual ~IRequestZBGetTodayCreditCallback(){};
	virtual void OnZBGetTodayCredit(ZBHttpGetTodayCreditTask* task, bool success, int errnum, const string& errmsg, const ZBHttpTodayCreditItem& configItem) = 0;
};
      
class ZBHttpGetTodayCreditTask : public ZBHttpRequestTask {
public:
	ZBHttpGetTodayCreditTask();
	virtual ~ZBHttpGetTodayCreditTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetTodayCreditCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetTodayCreditCallback* mpCallback;

};

#endif /* ZBHttpGetTodayCreditTask_H_ */
