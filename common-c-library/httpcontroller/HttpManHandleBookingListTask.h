/*
 * HttpManHandleBookingListTask.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.1.观众待处理的预约邀请列表
 */

#ifndef HttpManHandleBookingListTask_H_
#define HttpManHandleBookingListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpBookingInviteListItem.h"

class HttpManHandleBookingListTask;

class IRequestManHandleBookingListCallback {
public:
	virtual ~IRequestManHandleBookingListCallback(){};
	virtual void OnManHandleBookingList(HttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const HttpBookingInviteListItem& BookingListItem) = 0;
};
      
class HttpManHandleBookingListTask : public HttpRequestTask {
public:
	HttpManHandleBookingListTask();
	virtual ~HttpManHandleBookingListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestManHandleBookingListCallback* pCallback);

    /**
     * @param type                 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                    BookingListType type,
                    int start,
                    int step
                  );
    
    /**
     * 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
     */
    BookingListType GetType();
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
	IRequestManHandleBookingListCallback* mpCallback;
    // 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
    BookingListType mType;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
    
};

#endif /* HttpManHandleBookingListTask_H_ */
