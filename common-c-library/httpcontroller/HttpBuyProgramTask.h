/*
 * HttpBuyProgramTask.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.3.购买节目
 */

#ifndef HttpBuyProgramTask_H_
#define HttpBuyProgramTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"


class HttpBuyProgramTask;

class IRequestBuyProgramCallback {
public:
	virtual ~IRequestBuyProgramCallback(){};
	virtual void OnBuyProgram(HttpBuyProgramTask* task, bool success, int errnum, const string& errmsg, double leftCredit) = 0;
};
      
class HttpBuyProgramTask : public HttpRequestTask {
public:
	HttpBuyProgramTask();
	virtual ~HttpBuyProgramTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestBuyProgramCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& liveShowId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestBuyProgramCallback* mpCallback;
    // 节目ID
    string mLiveShowId;


};

#endif /* HttpBuyProgramTask_H */
