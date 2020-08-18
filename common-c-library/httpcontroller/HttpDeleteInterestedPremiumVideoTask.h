/*
 * HttpDeleteInterestedPremiumVideoTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.9.删除收藏的视频
 */

#ifndef HttpDeleteInterestedPremiumVideoTask_H_
#define HttpDeleteInterestedPremiumVideoTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpDeleteInterestedPremiumVideoTask;

class IRequestDeleteInterestedPremiumVideoCallback {
public:
	virtual ~IRequestDeleteInterestedPremiumVideoCallback(){};
	virtual void OnDeleteInterestedPremiumVideo(HttpDeleteInterestedPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId) = 0;
};
      
class HttpDeleteInterestedPremiumVideoTask : public HttpRequestTask {
public:
	HttpDeleteInterestedPremiumVideoTask();
	virtual ~HttpDeleteInterestedPremiumVideoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDeleteInterestedPremiumVideoCallback* pCallback);

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
	IRequestDeleteInterestedPremiumVideoCallback* mpCallback;
    
    string mVideoId;


};

#endif /* HttpDeleteInterestedPremiumVideoTask_H_ */
