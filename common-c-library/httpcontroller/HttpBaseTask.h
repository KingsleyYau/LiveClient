/*
 * HttpBaseTask.h
 *
 *  Created on: 2015-9-15
 *      Author: Max
 */

#ifndef HttpBaseTask_H_
#define HttpBaseTask_H_

#include "IHttpTask.h"

#include <common/KLog.h>

#include <string>
using namespace std;

class HttpBaseTask : public IHttpTask {
public:
	HttpBaseTask();
	virtual ~HttpBaseTask();

	void SetHttpTaskCallback(IHttpTaskCallback* callback);
	IHttpTaskCallback* GetHttpTaskCallback();

	// Implement IHttpTask
	virtual bool Start();
	virtual void Stop();
	virtual void Reset();

	virtual void OnTaskFinish();

protected:
	IHttpTaskCallback* mpHttpTaskCallback;

    // 是否可以开始请求
	bool mbCanStart;
};

#endif /* HttpBaseTask_H_ */
