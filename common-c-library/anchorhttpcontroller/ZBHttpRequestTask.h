/*
 * ZBHttpRequestTask.h
 *
 *  Created on: 2015-9-10
 *      Author: Max
 */

#ifndef ZBHttpRequestTask_H_
#define ZBHttpRequestTask_H_

#include <map>
using namespace std;

#include <json/json/json.h>

#include <httpclient/HttpRequestManager.h>

#include "ZBHttpRequestEnum.h"
#include "ZBHttpRequestDefine.h"
#include "ZBHttpBaseTask.h"

class ZBHttpRequestTask;
class ZBErrcodeHandler {
public:
	virtual ~ZBErrcodeHandler(){};
    
    /**
     * 自定义错误码处理器
     * @request 请求
     * @errnum 错误码
     * @return 是否可以继续执行
     */
	virtual bool ErrcodeHandle(const ZBHttpRequestTask* request, const string &errnum) = 0;
};

class ZBHttpRequestTask : public ZBHttpBaseTask, IHttpRequestManagerCallback {
public:
	ZBHttpRequestTask();
	virtual ~ZBHttpRequestTask();

    // 初始化
	void Init(HttpRequestManager *pHttpRequestManager);
    // 设置错误处理器
	void SetErrcodeHandler(ZBErrcodeHandler* pErrcodeHandler);

	// Implement BaseTask
	bool Start();
	void Stop();
	bool IsFinishOK();
	const char* GetErrCode();

protected:
    // 开始接口请求
	const HttpRequest* StartRequest();
    // 停止接口请求
	void StopRequest();

    // 处理公共头部
	bool ParseCommon(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata = NULL);
    // 处理直播公共头部
    bool ParseLiveCommon(const char* buf, int size, int &errnum, string &errmsg, Json::Value *data, Json::Value *errdata = NULL);
    // ios 支付的头部
    bool ParseIOSPaid(const char* buf, int size, string &code, Json::Value *data);
    // 子类处理业务
	virtual bool ParseData(const string& url, bool bFlag, const char* buf, int size) = 0;

	// Implement IHttpRequestManagerCallback
	void OnFinish(HttpRequest* request, bool bFlag, const char* buf, int size);

    // HTTP接口请求管理类
	HttpRequestManager* mpHttpRequestManager;
    // HTTP请求实例
	const HttpRequest* mpRequest;
    // HTTP请求路径
	string mPath;
    // HTTP请求参数
	HttpEntiy mHttpEntiy;
    // HTTP请求是否缓存结果
	bool mNoCache;

	bool mbFinishOK;
	string mErrCode;

    // 错误处理器
	ZBErrcodeHandler* mpErrcodeHandler;
};

#endif /* HttpRequestTask_H_ */
