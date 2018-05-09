/*
 * HttpAnchorGetNoReadNumProgramTask.h
 *
 *  Created on: 2018-4-23
 *      Author: Alex
 *        desc: 7.2.获取节目未读数
 */

#ifndef HttpAnchorGetNoReadNumProgramTask_H_
#define HttpAnchorGetNoReadNumProgramTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class HttpAnchorGetNoReadNumProgramTask;

class IRequestAnchorGetNoReadNumProgramCallback {
public:
	virtual ~IRequestAnchorGetNoReadNumProgramCallback(){};
	virtual void OnAnchorGetNoReadNumProgram(HttpAnchorGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) = 0;
};
      
class HttpAnchorGetNoReadNumProgramTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetNoReadNumProgramTask();
	virtual ~HttpAnchorGetNoReadNumProgramTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetNoReadNumProgramCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestAnchorGetNoReadNumProgramCallback* mpCallback;

};

#endif /* HttpAnchorGetNoReadNumProgramTask_H_ */
