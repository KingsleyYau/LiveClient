/*
 * HttpGetMyProfileTask.h
 *
 *  Created on: 2018-9-19
 *      Author: Alex
 *        desc: 6.18.查询个人信息
 */

#ifndef HttpGetMyProfileTask_H_
#define HttpGetMyProfileTask_H_

#include "HttpRequestTask.h"
#include "item/HttpProfileItem.h"

class HttpGetMyProfileTask;

class IRequestGetMyProfileCallback {
public:
	virtual ~IRequestGetMyProfileCallback(){};
	virtual void OnGetMyProfile(HttpGetMyProfileTask* task, bool success, const string& errnum, const string& errmsg, const HttpProfileItem& profileItem) = 0;
};
      
class HttpGetMyProfileTask : public HttpRequestTask {
public:
	HttpGetMyProfileTask();
	virtual ~HttpGetMyProfileTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetMyProfileCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetMyProfileCallback* mpCallback;
    

};

#endif /* HttpGetMyProfileTask_H_ */
