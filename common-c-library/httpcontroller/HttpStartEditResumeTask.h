/*
 * HttpStartEditResumeTask.h
 *
 *  Created on: 2018-9-20
 *      Author: Alex
 *        desc: 6.21.开始编辑简介触发计时
 */

#ifndef HttpStartEditResumeTask_H_
#define HttpStartEditResumeTask_H_

#include "HttpRequestTask.h"
#include "item/HttpVersionCheckItem.h"

class HttpStartEditResumeTask;

class IRequestStartEditResumeCallback {
public:
	virtual ~IRequestStartEditResumeCallback(){};
	virtual void OnStartEditResume(HttpStartEditResumeTask* task, bool success, const string& errnum, const string& errmsg) = 0;
};
      
class HttpStartEditResumeTask : public HttpRequestTask {
public:
	HttpStartEditResumeTask();
	virtual ~HttpStartEditResumeTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestStartEditResumeCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestStartEditResumeCallback* mpCallback;

};

#endif /* HttpStartEditResumeTask_H_ */
