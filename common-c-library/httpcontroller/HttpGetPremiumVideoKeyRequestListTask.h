/*
 * HttpGetPremiumVideoKeyRequestListTask.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.3.获取解码锁请求列表
 */

#ifndef HttpGetPremiumVideoKeyRequestListTask_H_
#define HttpGetPremiumVideoKeyRequestListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoAccessKeyItem.h"

class HttpGetPremiumVideoKeyRequestListTask;

class IRequestGetPremiumVideoKeyRequestListCallback {
public:
	virtual ~IRequestGetPremiumVideoKeyRequestListCallback(){};
	virtual void OnGetPremiumVideoKeyRequestList(HttpGetPremiumVideoKeyRequestListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoAccessKeyList& list) = 0;
};
      
class HttpGetPremiumVideoKeyRequestListTask : public HttpRequestTask {
public:
	HttpGetPremiumVideoKeyRequestListTask();
	virtual ~HttpGetPremiumVideoKeyRequestListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPremiumVideoKeyRequestListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  LSAccessKeyType type,
                  int start,
                  int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPremiumVideoKeyRequestListCallback* mpCallback;


};

#endif /* HttpGetPremiumVideoKeyRequestListTask_H_ */
