/*
 * HttpGetPremiumVideoListTask.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.2.获取付费视频列表
 */

#ifndef HttpGetPremiumVideoListTask_H_
#define HttpGetPremiumVideoListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoBaseInfoItem.h"

class HttpGetPremiumVideoListTask;

class IRequestGetPremiumVideoListCallback {
public:
	virtual ~IRequestGetPremiumVideoListCallback(){};
	virtual void OnGetPremiumVideoList(HttpGetPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoBaseInfoList& list) = 0;
};
      
class HttpGetPremiumVideoListTask : public HttpRequestTask {
public:
	HttpGetPremiumVideoListTask();
	virtual ~HttpGetPremiumVideoListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPremiumVideoListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& typeIds,
                  int start,
                  int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPremiumVideoListCallback* mpCallback;


};

#endif /* HttpGetPremiumVideoListTask_H_ */
