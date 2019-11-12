/*
 * HttpRetrieveBannerTask.h
 *
 *  Created on: 2019-08-08
 *      Author: Alex
 *        desc: 6.24.获取直播广告
 */

#ifndef HttpRetrieveBannerTask_H_
#define HttpRetrieveBannerTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpRetrieveBannerTask;

class IRequestRetrieveBannerCallback {
public:
	virtual ~IRequestRetrieveBannerCallback(){};
	virtual void OnRetrieveBanner(HttpRetrieveBannerTask* task, bool success, int errnum, const string& errmsg, const string& url) = 0;
};
      
class HttpRetrieveBannerTask : public HttpRequestTask {
public:
	HttpRetrieveBannerTask();
	virtual ~HttpRetrieveBannerTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestRetrieveBannerCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    string manId,
                    bool isAnchorPage,
                    LSBannerType bannerType
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestRetrieveBannerCallback* mpCallback;

};

#endif /* HttpRetrieveBannerTask_H_ */
