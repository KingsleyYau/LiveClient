/*
 * HttpGetEmoticonListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）
 */

#ifndef HttpGetEmoticonListTask_H_
#define HttpGetEmoticonListTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpEmoticonItem.h"

class HttpGetEmoticonListTask;

class IRequestGetEmoticonListCallback {
public:
	virtual ~IRequestGetEmoticonListCallback(){};
    virtual void OnGetEmoticonList(HttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const EmoticonItemList& listItem) = 0;
};

class HttpGetEmoticonListTask : public HttpRequestTask {
public:
	HttpGetEmoticonListTask();
	virtual ~HttpGetEmoticonListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetEmoticonListCallback* pCallback);

    /**
     * 
     */
    void SetParam(
                  );
  
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetEmoticonListCallback* mpCallback;


};

#endif /* HttpGetEmoticonListTask_H_ */
