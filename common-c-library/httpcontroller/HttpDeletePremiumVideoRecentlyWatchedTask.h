/*
 * HttpDeletePremiumVideoRecentlyWatchedTask.h
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *        desc: 18.7.删除最近播放的视频
 */

#ifndef HttpDeletePremiumVideoRecentlyWatchedTask_H_
#define HttpDeletePremiumVideoRecentlyWatchedTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpDeletePremiumVideoRecentlyWatchedTask;

class IRequestDeletePremiumVideoRecentlyWatchedCallback {
public:
	virtual ~IRequestDeletePremiumVideoRecentlyWatchedCallback(){};
	virtual void OnDeletePremiumVideoRecentlyWatched(HttpDeletePremiumVideoRecentlyWatchedTask* task, bool success, int errnum, const string& errmsg, const string& watchedId) = 0;
};
      
class HttpDeletePremiumVideoRecentlyWatchedTask : public HttpRequestTask {
public:
	HttpDeletePremiumVideoRecentlyWatchedTask();
	virtual ~HttpDeletePremiumVideoRecentlyWatchedTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDeletePremiumVideoRecentlyWatchedCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& watchedId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestDeletePremiumVideoRecentlyWatchedCallback* mpCallback;
    
    string mWatchedId;


};

#endif /* HttpDeletePremiumVideoRecentlyWatchedTask_H_ */
