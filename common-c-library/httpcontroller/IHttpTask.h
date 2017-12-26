/*
 * ITask.h
 *
 *  Created on: 2015-9-11
 *      Author: Max
 */

#ifndef IHTTPTASK_H_
#define IHTTPTASK_H_

#include <httpclient/HttpLiveShowLog.h>

class IHttpTask {
public:
	virtual ~IHttpTask(){};
	virtual bool Start() = 0;
	virtual void Stop() = 0;
	virtual bool IsFinishOK() = 0;
	virtual const char* GetErrCode() = 0;
};

class IHttpTaskCallback {
public:
	virtual ~IHttpTaskCallback(){};
	virtual void OnTaskFinish(IHttpTask* pTask) = 0;
};
#endif /* IHTTPTASK_H_ */
