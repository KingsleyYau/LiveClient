/*
 * HttpAddInterestedPremiumVideoTask.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *        desc: 18.10.添加收藏的视频
 */

#ifndef HttpAddInterestedPremiumVideoTask_H_
#define HttpAddInterestedPremiumVideoTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpAddInterestedPremiumVideoTask;

class IRequestAddInterestedPremiumVideoCallback {
public:
	virtual ~IRequestAddInterestedPremiumVideoCallback(){};
	virtual void OnAddInterestedPremiumVideo(HttpAddInterestedPremiumVideoTask* task, bool success, int errnum, const string& errmsg, const string& videoId) = 0;
};
      
class HttpAddInterestedPremiumVideoTask : public HttpRequestTask {
public:
	HttpAddInterestedPremiumVideoTask();
	virtual ~HttpAddInterestedPremiumVideoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAddInterestedPremiumVideoCallback* pCallback);

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
	IRequestAddInterestedPremiumVideoCallback* mpCallback;
    
    string mVideoId;


};

#endif /* HttpAddInterestedPremiumVideoTask_H_ */
