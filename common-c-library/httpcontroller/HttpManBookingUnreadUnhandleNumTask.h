/*
 * HttpManBookingUnreadUnhandleNumTask.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *        desc: 4.4.获取预约邀请未读或待处理数量
 */

#ifndef HttpManBookingUnreadUnhandleNumTask_H_
#define HttpManBookingUnreadUnhandleNumTask_H_

#include "HttpRequestTask.h"
#include "item/HttpBookingUnreadUnhandleNumItem.h"

class HttpManBookingUnreadUnhandleNumTask;

class IRequestManBookingUnreadUnhandleNumCallback {
public:
	virtual ~IRequestManBookingUnreadUnhandleNumCallback(){};
	virtual void OnManBookingUnreadUnhandleNum(HttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg, const HttpBookingUnreadUnhandleNumItem& item) = 0;
};
      
class HttpManBookingUnreadUnhandleNumTask : public HttpRequestTask {
public:
	HttpManBookingUnreadUnhandleNumTask();
	virtual ~HttpManBookingUnreadUnhandleNumTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestManBookingUnreadUnhandleNumCallback* pCallback);

    /**
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestManBookingUnreadUnhandleNumCallback* mpCallback;
    
};

#endif /* HttpManBookingUnreadUnhandleNumTask_H_ */
