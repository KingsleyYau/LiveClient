/*
 * HttpGetAnchorPremiumVideoListTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.12.获取某主播的视频列表
 */

#ifndef HttpGetAnchorPremiumVideoListTask_H_
#define HttpGetAnchorPremiumVideoListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoBaseInfoItem.h"

class HttpGetAnchorPremiumVideoListTask;

class IRequestGetAnchorPremiumVideoListCallback {
public:
	virtual ~IRequestGetAnchorPremiumVideoListCallback(){};
	virtual void OnGetAnchorPremiumVideoList(HttpGetAnchorPremiumVideoListTask* task, bool success, int errnum, const string& errmsg, const PremiumVideoBaseInfoList& list) = 0;
};
      
class HttpGetAnchorPremiumVideoListTask : public HttpRequestTask {
public:
	HttpGetAnchorPremiumVideoListTask();
	virtual ~HttpGetAnchorPremiumVideoListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAnchorPremiumVideoListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& anchorId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetAnchorPremiumVideoListCallback* mpCallback;

};

#endif /* HttpGetAnchorPremiumVideoListTask_H_ */
