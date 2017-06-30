/*
 * HttpGetLiveRoomConfigTask.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）
 */

#ifndef HttpGetLiveRoomConfigTask_H_
#define HttpGetLiveRoomConfigTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"

#include "item/HttpLiveRoomConfigItem.h"

class HttpGetLiveRoomConfigTask;

class IRequestGetLiveRoomConfigCallback {
public:
	virtual ~IRequestGetLiveRoomConfigCallback(){};
	virtual void OnGetLiveRoomConfig(HttpGetLiveRoomConfigTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomConfigItem& item) = 0;
};

class HttpGetLiveRoomConfigTask : public HttpRequestTask {
public:
	HttpGetLiveRoomConfigTask();
	virtual ~HttpGetLiveRoomConfigTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomConfigCallback* pCallback);

    /**
     *
     */
    void SetParam();
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveRoomConfigCallback* mpCallback;

};

#endif /* HttpGetLiveRoomConfigTask_H_ */
