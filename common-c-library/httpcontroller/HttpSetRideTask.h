/*
 * HttpSetRideTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.4.使用／取消座驾
 */

#ifndef HttpSetRideTask_H_
#define HttpSetRideTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpSetRideTask;

class IRequestSetRideCallback {
public:
	virtual ~IRequestSetRideCallback(){};
	virtual void OnSetRide(HttpSetRideTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSetRideTask : public HttpRequestTask {
public:
	HttpSetRideTask();
	virtual ~HttpSetRideTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetRideCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& rideId
                  );
    
    const string& GetRideId();
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetRideCallback* mpCallback;
    // 座驾ID
    string mRideId;
};

#endif /* HttpSetRideTask_H_ */
