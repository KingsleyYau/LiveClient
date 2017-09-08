/*
 * HttpSendBookingRequestTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 4.6.新建预约邀请
 */

#ifndef HttpSendBookingRequestTask_H_
#define HttpSendBookingRequestTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSendBookingRequestTask;

class IRequestSendBookingRequestCallback {
public:
	virtual ~IRequestSendBookingRequestCallback(){};
	virtual void OnSendBookingRequest(HttpSendBookingRequestTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSendBookingRequestTask : public HttpRequestTask {
public:
	HttpSendBookingRequestTask();
	virtual ~HttpSendBookingRequestTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendBookingRequestCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string userId,
                  const string timeId,
                  long bookTime,
                  const string giftId,
                  int giftNum
                  );
    
    /**
     *  主播ID
     */
    const string& GetUserId();
    
    const string& GetTimeId();
    
    long GetBookTime();
    
    const string& GetGiftId();
    
    int GetGiftNum();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendBookingRequestCallback* mpCallback;
    
    // 主播ID
    string mUserId;
    // 预约时间ID
    string mTimeId;
    // 预约时间
    long   mBookTime;
    // 礼物ID
    string mGiftId;
    // 礼物数量
    int mGiftNum;

};

#endif /* HttpSendBookingRequestTask_H_ */
