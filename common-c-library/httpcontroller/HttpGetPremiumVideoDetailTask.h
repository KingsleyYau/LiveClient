/*
 * HttpGetPremiumVideoDetailTask.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.13.获取视频详情
 */

#ifndef HttpGetPremiumVideoDetailTask_H_
#define HttpGetPremiumVideoDetailTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoDetailItem.h"

class HttpGetPremiumVideoDetailTask;

class IRequestGetPremiumVideoDetailCallback {
public:
	virtual ~IRequestGetPremiumVideoDetailCallback(){};
	virtual void OnGetPremiumVideoDetail(HttpGetPremiumVideoDetailTask* task, bool success, int errnum, const string& errmsg, const HttpPremiumVideoDetailItem& item) = 0;
};
      
class HttpGetPremiumVideoDetailTask : public HttpRequestTask {
public:
	HttpGetPremiumVideoDetailTask();
	virtual ~HttpGetPremiumVideoDetailTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPremiumVideoDetailCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& videoId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPremiumVideoDetailCallback* mpCallback;


};

#endif /* HttpGetPremiumVideoDetailTask_H_ */
