/*
 * HttpGetPremiumVideoTypeListTask.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *        desc: 18.1.获取付费视频分类列表
 */

#ifndef HttpGetPremiumVideoTypeListTask_H_
#define HttpGetPremiumVideoTypeListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPremiumVideoTypeItem.h"

class HttpGetPremiumVideoTypeListTask;

class IRequestGetPremiumVideoTypeListCallback {
public:
	virtual ~IRequestGetPremiumVideoTypeListCallback(){};
	virtual void OnGetPremiumVideoTypeList(HttpGetPremiumVideoTypeListTask* task, bool success, int errnum, const string& errmsg, const PremiumVideoTypeList& list) = 0;
};
      
class HttpGetPremiumVideoTypeListTask : public HttpRequestTask {
public:
	HttpGetPremiumVideoTypeListTask();
	virtual ~HttpGetPremiumVideoTypeListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPremiumVideoTypeListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPremiumVideoTypeListCallback* mpCallback;


};

#endif /* HttpGetPremiumVideoTypeListTask_H_ */
