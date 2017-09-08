/*
 * HttpGetCreateBookingInfoTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 4.5.获取新建预约邀请信息
 */

#ifndef HttpGetCreateBookingInfoTask_H_
#define HttpGetCreateBookingInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGetCreateBookingInfoItem.h"

class HttpGetCreateBookingInfoTask;

class IRequestGetCreateBookingInfoCallback {
public:
	virtual ~IRequestGetCreateBookingInfoCallback(){};
	virtual void OnGetCreateBookingInfo(HttpGetCreateBookingInfoTask* task, bool success, int errnum, const string& errmsg, const HttpGetCreateBookingInfoItem& item) = 0;
};
      
class HttpGetCreateBookingInfoTask : public HttpRequestTask {
public:
	HttpGetCreateBookingInfoTask();
	virtual ~HttpGetCreateBookingInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCreateBookingInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& userId
                  );
    
    /**
     *  主播ID
     */
    const string& GetUserId();
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCreateBookingInfoCallback* mpCallback;
    
    // 主播ID
    string mUserId;

};

#endif /* HttpGetTalentStatusTask_H_ */
