/*
 * HttpSendEmfTask.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.5.发送信件
 */

#ifndef HttpSendEmfTask_H_
#define HttpSendEmfTask_H_

#include "HttpRequestTask.h"
#include "item/HttpLetterListItem.h"

class HttpSendEmfTask;

class IRequestSendEmfCallback {
public:
	virtual ~IRequestSendEmfCallback(){};
	virtual void OnSendEmf(HttpSendEmfTask* task, bool success, int errnum, const string& errmsg, const string& emfId) = 0;
};
      
class HttpSendEmfTask : public HttpRequestTask {
public:
	HttpSendEmfTask();
	virtual ~HttpSendEmfTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendEmfCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  string anchorId,
                  string loiId,
                  string emfId,
                  string content,
                  list<string> imgList,
                  LSLetterComsumeType comsumeType,
                  string sayHiResponseId,
                  bool isSchedule,
                  string timeZoneId,
                  string startTime,
                  int duration
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendEmfCallback* mpCallback;

};

#endif /* HttpSendEmfTask_H_ */
