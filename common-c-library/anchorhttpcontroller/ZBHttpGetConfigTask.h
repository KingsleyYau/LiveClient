/*
 * ZBHttpGetConfigTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 5.1.同步配置
 */

#ifndef ZBHttpGetConfigTask_H_
#define ZBHttpGetConfigTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpConfigItem.h"

class ZBHttpGetConfigTask;

class IRequestZBGetConfigCallback {
public:
	virtual ~IRequestZBGetConfigCallback(){};
	virtual void OnZBGetConfig(ZBHttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const ZBHttpConfigItem& configItem) = 0;
};
      
class ZBHttpGetConfigTask : public ZBHttpRequestTask {
public:
	ZBHttpGetConfigTask();
	virtual ~ZBHttpGetConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetConfigCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetConfigCallback* mpCallback;

};

#endif /* ZBHttpGiftListTask_H_ */
