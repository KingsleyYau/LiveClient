/*
 * ZBHttpBaseTask.h
 *
 *  Created on: 2018-3-1
 *      Author: Max
 */

#ifndef ZBHttpBaseTask_H_
#define ZBHttpBaseTask_H_

#include "IZBHttpTask.h"

#include <common/KLog.h>

#include <string>
using namespace std;

class ZBHttpBaseTask : public IZBHttpTask {
public:
	ZBHttpBaseTask();
	virtual ~ZBHttpBaseTask();

	void SetHttpTaskCallback(IZBHttpTaskCallback* callback);
	IZBHttpTaskCallback* GetHttpTaskCallback();

	// Implement IHttpTask
	virtual bool Start();
	virtual void Stop();
	virtual void Reset();

	virtual void OnTaskFinish();

protected:
	IZBHttpTaskCallback* mpHttpTaskCallback;

    // 是否可以开始请求
	bool mbCanStart;
};

#endif /* ZBHttpBaseTask_H_ */
