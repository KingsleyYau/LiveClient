/*
 * LSLiveChatRequestSettingController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTSETTINGCONTROLLER_H_
#define LSLIVECHATREQUESTSETTINGCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include <json/json/json.h>

#include "LSLiveChatRequestSettingDefine.h"

typedef void (*OnChangePassword)(long requestId, bool success, string errnum, string errmsg);

typedef struct LSLiveChatRequestSettingControllerCallback {
	OnChangePassword onChangePassword;
} LSLiveChatRequestSettingControllerCallback;

class LSLiveChatRequestSettingController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestSettingController(LSLiveChatHttpRequestManager* pHttpRequestManager, LSLiveChatRequestSettingControllerCallback callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestSettingController();

	/**
	 * 3.1.修改密码
	 * @param oldPassword	新密码
	 * @param newPassword	旧密码
	 * @param callback
	 * @return				请求唯一标识
	 */
	long ChangePassword(string oldPassword, string newPassword);

protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestSettingControllerCallback mLSLiveChatRequestSettingControllerCallback;
};

#endif /* LSLIVECHATREQUESTSETTINGCONTROLLER_H_ */
