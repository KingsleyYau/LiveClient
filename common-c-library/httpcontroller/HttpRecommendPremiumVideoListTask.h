/*
 * HttpRecommendPremiumVideoListTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.11.获取可能感兴趣的推荐视频列表
 */

#ifndef HttpRecommendPremiumVideoListTask_H_
#define HttpRecommendPremiumVideoListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoBaseInfoItem.h"

class HttpRecommendPremiumVideoListTask;

class IRequestRecommendPremiumVideoListCallback {
public:
	virtual ~IRequestRecommendPremiumVideoListCallback(){};
	virtual void OnRecommendPremiumVideoList(HttpRecommendPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, int num, const PremiumVideoBaseInfoList& list) = 0;
};
      
class HttpRecommendPremiumVideoListTask : public HttpRequestTask {
public:
	HttpRecommendPremiumVideoListTask();
	virtual ~HttpRecommendPremiumVideoListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRecommendPremiumVideoListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int num
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRecommendPremiumVideoListCallback* mpCallback;
    int mNum;

};

#endif /* HttpRecommendPremiumVideoListTask_H_ */
