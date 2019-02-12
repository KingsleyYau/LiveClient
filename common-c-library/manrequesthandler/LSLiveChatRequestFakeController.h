/*
 * LSLiveChatRequestFakeController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTFAKECONTROLLER_H_
#define LSLIVECHATREQUESTFAKECONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include <json/json/json.h>

#include "LSLiveChatRequestFakeDefine.h"

#include "item/LSLCCheckServerItem.h"

class ILSLiveChatRequestFakeControllerCallback
{
public:
    ILSLiveChatRequestFakeControllerCallback() {}
    virtual ~ILSLiveChatRequestFakeControllerCallback() {}
public:
    virtual void OnCheckServer(long requestId, bool success, LSLCCheckServerItem item, string errnum, string errmsg) = 0;
};

class LSLiveChatRequestFakeController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestFakeController(LSLiveChatHttpRequestManager* pHttpRequestManager, ILSLiveChatRequestFakeControllerCallback* pLSLiveChatRequestFakeControllerCallback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestFakeController();

    /**
     * 2.1.检查真假服务器
     * @param email				账号
     * @return					请求唯一标识
     */
    long CheckServer(
    		string email
    		);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	ILSLiveChatRequestFakeControllerCallback* mpLSLiveChatRequestFakeControllerCallback;
};

#endif /* LSLiveChatRequestFakeController_H_ */
