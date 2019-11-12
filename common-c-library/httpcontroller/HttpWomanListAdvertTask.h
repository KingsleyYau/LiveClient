/*
 * HttpWomanListAdvertTask.h
 *
 *  Created on: 2019-10-08
 *      Author: Alex
 *        desc: 6.25.获取直播主播列表广告
 */

#ifndef HttpWomanListAdvertTask_H_
#define HttpWomanListAdvertTask_H_

#include "HttpRequestTask.h"
#include "item/HttpAdWomanListAdvertItem.h"

class HttpWomanListAdvertTask;

class IRequestWomanListAdvertCallback {
public:
	virtual ~IRequestWomanListAdvertCallback(){};
	virtual void OnWomanListAdvert(HttpWomanListAdvertTask* task, bool success, int errnum, const string& errmsg, const HttpAdWomanListAdvertItem& advertItem) = 0;
};
      
class HttpWomanListAdvertTask : public HttpRequestTask {
public:
	HttpWomanListAdvertTask();
	virtual ~HttpWomanListAdvertTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestWomanListAdvertCallback* pCallback);

    /**
     *
     */
    void SetParam(
                   const string& deviceId,
                   LSAdvertSpaceType adspaceId
                  );

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestWomanListAdvertCallback* mpCallback;

};

#endif /* HttpWomanListAdvertTask_H_ */
