/*
 * HttpCloseAdAnchorListTask.h
 *
 *  Created on: 2017-9-15
 *      Author: Alex
 *        desc: 6.5.关闭QN广告列表
 */

#ifndef HttpCloseAdAnchorListTask_H_
#define HttpCloseAdAnchorListTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpCloseAdAnchorListTask;

class IRequestCloseAdAnchorListCallback {
public:
	virtual ~IRequestCloseAdAnchorListCallback(){};
	virtual void OnCloseAdAnchorList(HttpCloseAdAnchorListTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpCloseAdAnchorListTask : public HttpRequestTask {
public:
	HttpCloseAdAnchorListTask();
	virtual ~HttpCloseAdAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestCloseAdAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestCloseAdAnchorListCallback* mpCallback;

};

#endif /* HttpCloseAdAnchorListTask_H_ */
