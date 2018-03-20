/*
 * ZBHttpManHandleBookingListTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 4.1.获取预约邀请列表
 */

#ifndef ZBHttpManHandleBookingListTask_H_
#define ZBHttpManHandleBookingListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/ZBHttpBookingInviteListItem.h"

class ZBHttpManHandleBookingListTask;

class IRequestZBManHandleBookingListCallback {
public:
	virtual ~IRequestZBManHandleBookingListCallback(){};
	virtual void OnZBManHandleBookingList(ZBHttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingInviteListItem& BookingListItem) = 0;
};
      
class ZBHttpManHandleBookingListTask : public ZBHttpRequestTask {
public:
	ZBHttpManHandleBookingListTask();
	virtual ~ZBHttpManHandleBookingListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBManHandleBookingListCallback* pCallback);

    /**
     * @param type                 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                    ZBBookingListType type,
                    int start,
                    int step
                  );
    
    /**
     * 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
     */
    ZBBookingListType GetType();
    /**
     * 获取起始，用于分页，表示从第几个元素开始获取
     */
    int GetStart();
    /**
     * 步长，用于分页，表示本次请求获取多少个元素
     */
    int GetStep();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBManHandleBookingListCallback* mpCallback;
    // 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
    ZBBookingListType mType;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
    
};

#endif /* ZBHttpManHandleBookingListTask_H_ */
