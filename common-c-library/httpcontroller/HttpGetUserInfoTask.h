/*
 * HttpGetUserInfoTask.h
 *
 *  Created on: 2017-11-01
 *      Author: Alex
 *        desc: 6.10.获取主播/观众信息

 */

#ifndef HttpGetUserInfoTask_H_
#define HttpGetUserInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpUserInfoItem.h"

class HttpGetUserInfoTask;

class IRequestGetUserInfoCallback {
public:
	virtual ~IRequestGetUserInfoCallback(){};
	virtual void OnGetUserInfo(HttpGetUserInfoTask* task, bool success, int errnum, const string& errmsg, const HttpUserInfoItem& userItem) = 0;
};
      
class HttpGetUserInfoTask : public HttpRequestTask {
public:
	HttpGetUserInfoTask();
	virtual ~HttpGetUserInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetUserInfoCallback* pCallback);

    /**
     *
     */
    void SetParam( const string& userId
                  );
    
    const string& GetUserId();
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetUserInfoCallback* mpCallback;
    
    string mUserId;

};

#endif /* HttpGetUserInfoTask_H_ */
