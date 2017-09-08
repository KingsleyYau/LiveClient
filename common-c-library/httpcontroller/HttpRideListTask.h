/*
 * HttpRideListTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 5.3.获取座驾列表
 */

#ifndef HttpRideListTask_H_
#define HttpRideListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpRideItem.h"

class HttpRideListTask;

class IRequestRideListCallback {
public:
	virtual ~IRequestRideListCallback(){};
	virtual void OnRideList(HttpRideListTask* task, bool success, int errnum, const string& errmsg, const RideList& list) = 0;
};
      
class HttpRideListTask : public HttpRequestTask {
public:
	HttpRideListTask();
	virtual ~HttpRideListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRideListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRideListCallback* mpCallback;
    

};

#endif /* HttpRideListTask_H_ */
