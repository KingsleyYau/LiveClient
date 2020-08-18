/*
 * HttpGetInterestedPremiumVideoListTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.8.获取收藏的视频列表
 */

#ifndef HttpGetInterestedPremiumVideoListTask_H_
#define HttpGetInterestedPremiumVideoListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoBaseInfoItem.h"

class HttpGetInterestedPremiumVideoListTask;

class IRequestGetInterestedPremiumVideoListCallback {
public:
	virtual ~IRequestGetInterestedPremiumVideoListCallback(){};
	virtual void OnGetInterestedPremiumVideoList(HttpGetInterestedPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoBaseInfoList& list) = 0;
};
      
class HttpGetInterestedPremiumVideoListTask : public HttpRequestTask {
public:
	HttpGetInterestedPremiumVideoListTask();
	virtual ~HttpGetInterestedPremiumVideoListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetInterestedPremiumVideoListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int start,
                  int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetInterestedPremiumVideoListCallback* mpCallback;


};

#endif /* HttpGetInterestedPremiumVideoListTask_H_ */
