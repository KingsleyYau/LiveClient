/*
 * ZBHttpManBookingUnreadUnhandleNumTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.4.获取预约邀请未读或待处理数量
 */

#ifndef ZBHttpManBookingUnreadUnhandleNumTask_H_
#define ZBHttpManBookingUnreadUnhandleNumTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/ZBHttpBookingUnreadUnhandleNumItem.h"

class ZBHttpManBookingUnreadUnhandleNumTask;

class IRequestZBGetScheduleListNoReadNumCallback {
public:
	virtual ~IRequestZBGetScheduleListNoReadNumCallback(){};
	virtual void OnZBGetScheduleListNoReadNum(ZBHttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingUnreadUnhandleNumItem& item) = 0;
};
      
class ZBHttpManBookingUnreadUnhandleNumTask : public ZBHttpRequestTask {
public:
	ZBHttpManBookingUnreadUnhandleNumTask();
	virtual ~ZBHttpManBookingUnreadUnhandleNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetScheduleListNoReadNumCallback* pCallback);

    /**
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetScheduleListNoReadNumCallback* mpCallback;
    
};

#endif /* HttpManBookingUnreadUnhandleNumTask_H_ */
