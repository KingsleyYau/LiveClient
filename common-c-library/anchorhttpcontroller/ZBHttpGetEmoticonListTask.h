/*
 * ZBHttpGetEmoticonListTask.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 3.6.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）
 */

#ifndef ZBHttpGetEmoticonListTask_H_
#define ZBHttpGetEmoticonListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/ZBHttpEmoticonItem.h"

class ZBHttpGetEmoticonListTask;

class IRequestZBGetEmoticonListCallback {
public:
	virtual ~IRequestZBGetEmoticonListCallback(){};
    virtual void OnZBGetEmoticonList(ZBHttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const ZBEmoticonItemList& listItem) = 0;
};

class ZBHttpGetEmoticonListTask : public ZBHttpRequestTask {
public:
	ZBHttpGetEmoticonListTask();
	virtual ~ZBHttpGetEmoticonListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBGetEmoticonListCallback* pCallback);

    /**
     * 
     */
    void SetParam(
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBGetEmoticonListCallback* mpCallback;


};

#endif /* ZBHttpGetEmoticonListTask_H_ */
