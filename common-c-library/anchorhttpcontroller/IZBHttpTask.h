/*
 * ITask.h
 *
 *  Created on: 2018-3-1
 *      Author: Max
 */

#ifndef IZBHTTPTASK_H_
#define IZBHTTPTASK_H_

#include <httpclient/HttpLiveShowLog.h>

class IZBHttpTask {
public:
	virtual ~IZBHttpTask(){};
	virtual bool Start() = 0;
	virtual void Stop() = 0;
	virtual bool IsFinishOK() = 0;
	virtual const char* GetErrCode() = 0;
};

class IZBHttpTaskCallback {
public:
	virtual ~IZBHttpTaskCallback(){};
	virtual void OnTaskFinish(IZBHttpTask* pTask) = 0;
};
#endif /* IZBHTTPTASK_H_ */
