/*
 * HttpBannerTask.h
 *
 *  Created on: 2017-10-18
 *      Author: Alex
 *        desc: 6.9.获取Hot/Following列表头部广告

 */

#ifndef HttpBannerTask_H_
#define HttpBannerTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"

class HttpBannerTask;

class IRequestBannerCallback {
public:
	virtual ~IRequestBannerCallback(){};
	virtual void OnBanner(HttpBannerTask* task, bool success, int errnum, const string& errmsg, const string& bannerImg, const string& bannerLink, const string& bannerName) = 0;
};
      
class HttpBannerTask : public HttpRequestTask {
public:
	HttpBannerTask();
	virtual ~HttpBannerTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestBannerCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestBannerCallback* mpCallback;

};

#endif /* HttpBannerTask_H_ */
