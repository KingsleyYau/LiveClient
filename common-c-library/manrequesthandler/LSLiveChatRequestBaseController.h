/*
 * LSLiveChatRequestBaseController.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLiveChatRequestBaseController_H_
#define LSLiveChatRequestBaseController_H_

#include <map>
using namespace std;

#include "LSLiveChatHttpRequestManager.h"

#include <json/json/json.h>
#include <common/KSafeMap.h>

#include <xml/tinyxml.h>

#include "LSLiveChatRequestDefine.h"

// add by samson 2015-04-20
typedef map<long, void*> RequestCustomParamMap;

typedef KSafeMap<string, long> RequestFileDownloadMap;

class LSLiveChatRequestBaseController {
public:
	LSLiveChatRequestBaseController();
	virtual ~LSLiveChatRequestBaseController();

	void SetHttpRequestManager(LSLiveChatHttpRequestManager* pHttpRequestManager);

	long StartRequest(string url, HttpEntiy& entiy, ILSLiveChatHttpRequestManagerCallback* callback = NULL, SiteType type = AppSite, bool bNoCache = false);
	bool StopRequest(long requestId, bool bWait = false);

protected:
	bool HandleResult(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata = NULL);
	bool HandleResult(const char* buf, int size, string &errnum, string &errmsg, TiXmlDocument &doc);
    // HandleResult是之前QN的json解析函数， 下面的是迁移到直播livechat的json解析函数， HandleResult没有删掉是因为迁移了一部分没有用的代码用到， 暂时livechat调用下面的，
    bool HandleLiveChatReqult(const char* buf, int size, string &errnum, string &errmsg, Json::Value *data, Json::Value *errdata = NULL);
    // 将直播的http接口6.2.获取帐号余额
    bool HandleLSResult(const char* buf, int size, int &errnum, string &errmsg, Json::Value *data, Json::Value *errdata = NULL);

	/**
	 * 必须在回调完调用, 回调完成后获取不了
	 */
	string GetContentTypeById(long requestId);

	// 获取body总数及已下载数
	void GetRecvLength(long requestId, int& total, int& recv);

private:
	LSLiveChatHttpRequestManager* mpHttpRequestManager;

protected:
	RequestCustomParamMap	mCustomParamMap;
	RequestFileDownloadMap  mRequestFileDownloadMap;
};

#endif /* LSLiveChatRequestBaseController_H_ */
