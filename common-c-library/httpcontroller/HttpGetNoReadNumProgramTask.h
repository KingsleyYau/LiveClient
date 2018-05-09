/*
 * HttpGetNoReadNumProgramTask.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.1.获取节目列表未读
 */

#ifndef HttpGetNoReadNumProgramTask_H_
#define HttpGetNoReadNumProgramTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetNoReadNumProgramTask;

class IRequestGetNoReadNumProgramCallback {
public:
	virtual ~IRequestGetNoReadNumProgramCallback(){};
	virtual void OnGetNoReadNumProgram(HttpGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) = 0;
};
      
class HttpGetNoReadNumProgramTask : public HttpRequestTask {
public:
	HttpGetNoReadNumProgramTask();
	virtual ~HttpGetNoReadNumProgramTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetNoReadNumProgramCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetNoReadNumProgramCallback* mpCallback;


};

#endif /* HttpGetNoReadNumProgramTask_H_ */
