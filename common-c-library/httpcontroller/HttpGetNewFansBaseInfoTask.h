/*
 * HttpGetNewFansBaseInfoTask.h
 *
 *  Created on: 2017-8-30
 *      Author: Alex
 *        desc: 3.12.获取指定观众信息
 */

#ifndef HttpGetNewFansBaseInfoTask_H_
#define HttpGetNewFansBaseInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLiveFansItem.h"

class HttpGetNewFansBaseInfoTask;

class IRequestGetNewFansBaseInfoCallback {
public:
	virtual ~IRequestGetNewFansBaseInfoCallback(){};
	virtual void OnGetNewFansBaseInfo(HttpGetNewFansBaseInfoTask* task, bool success, int errnum, const string& errmsg, const HttpLiveFansItem& item) = 0;
};
      
class HttpGetNewFansBaseInfoTask : public HttpRequestTask {
public:
	HttpGetNewFansBaseInfoTask();
	virtual ~HttpGetNewFansBaseInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetNewFansBaseInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& userId
                  );
    
    const string& GetUserId();
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetNewFansBaseInfoCallback* mpCallback;
    // 观众ID
    string mUserId;

};

#endif /* HttpGetNewFansBaseInfoTask_H_ */
