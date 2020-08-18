/*
 * HttpGetPremiumVideoRecentlyWatchedListTask.h
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *        desc: 18.6.获取最近播放的视频列表
 */

#ifndef HttpGetPremiumVideoRecentlyWatchedListTask_H_
#define HttpGetPremiumVideoRecentlyWatchedListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoRecentlyWatchedItem.h"

class HttpGetPremiumVideoRecentlyWatchedListTask;

class IRequestGetPremiumVideoRecentlyWatchedListCallback {
public:
	virtual ~IRequestGetPremiumVideoRecentlyWatchedListCallback(){};
	virtual void OnGetPremiumVideoRecentlyWatchedList(HttpGetPremiumVideoRecentlyWatchedListTask* task, bool success, int errnum, const string& errmsg, int totalCount, const PremiumVideoRecentlyWatchedList& list) = 0;
};
      
class HttpGetPremiumVideoRecentlyWatchedListTask : public HttpRequestTask {
public:
	HttpGetPremiumVideoRecentlyWatchedListTask();
	virtual ~HttpGetPremiumVideoRecentlyWatchedListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPremiumVideoRecentlyWatchedListCallback* pCallback);

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
	IRequestGetPremiumVideoRecentlyWatchedListCallback* mpCallback;

};

#endif /* HttpGetPremiumVideoRecentlyWatchedListTask_H_ */
